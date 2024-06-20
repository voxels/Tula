//
//  ARSessionManager.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/9/24.
//

struct PlacementDragState {
    var draggedObject: PlaceableObject
    var initialPosition: SIMD3<Float>
    var position: SIMD3<Float>

    @MainActor
    init(objectToDrag: PlaceableObject, initialPosition:SIMD3<Float>, position:SIMD3<Float> = .zero) {
        self.draggedObject = objectToDrag
        self.initialPosition = initialPosition
        self.position = position
    }
}

struct DragState {
    var draggedObject: PlacedObject
    var initialPosition: SIMD3<Float>
    var initialOrientation:simd_quatf
    
    @MainActor
    init(objectToDrag: PlacedObject) {
        draggedObject = objectToDrag
        initialPosition = objectToDrag.position
        initialOrientation = objectToDrag.orientation
    }
}


import Foundation
import ARKit
import RealityKit
import QuartzCore
import SwiftUI

@Observable
final class ARSessionManager {
    private let worldTracking = WorldTrackingProvider()
    private let planeDetection = PlaneDetectionProvider()
    private let handTracking = HandTrackingProvider()
    
    private var planeAnchorHandler: PlaneAnchorHandler
    private var persistenceManager: PersistenceManager
    
    var appState: TulaAppModel? = nil {
        didSet {
            persistenceManager.placeableObjectsByFileName = appState?.placeableObjectsByFileName ?? [:]
        }
    }
    
    public var placementDrag:PlacementDragState? = nil

    private var currentDrag: DragState? = nil {
        didSet {
            placementState.dragInProgress = currentDrag != nil
        }
    }
    
    var placementState = PlacementState()

    var rootEntity: Entity
    
    private let deviceLocation: Entity
    private let handLocation: Entity
    private let raycastOrigin: Entity
    private let placementLocation: Entity
    private weak var placementTooltip: Entity? = nil
    weak var dragTooltip: Entity? = nil
    weak var deleteButton: Entity? = nil
    
    // Place objects on planes with a small gap.
    static private let placedObjectsOffsetOnPlanes: Float = 0.01
    
    // Snap dragged objects to a nearby horizontal plane within +/- 4 centimeters.
    static private let snapToPlaneDistanceForDraggedObjects: Float = 0.04
    
    @MainActor
    init() {
        let root = Entity()
        rootEntity = root
        placementLocation = Entity()
        deviceLocation = Entity()
        handLocation = Entity()
        raycastOrigin = Entity()
        
        planeAnchorHandler = PlaneAnchorHandler(rootEntity: root)
        persistenceManager = PersistenceManager(handTracking: handTracking, worldTracking: worldTracking, rootEntity: root)
        persistenceManager.loadPersistedObjects()
        
        rootEntity.addChild(placementLocation)
        
        deviceLocation.addChild(raycastOrigin)
        
        // Angle raycasts 15 degrees down.
        let raycastDownwardAngle = 15.0 * (Float.pi / 180)
        raycastOrigin.orientation = simd_quatf(angle: -raycastDownwardAngle, axis: [1.0, 0.0, 0.0])
    }
    
    func saveWorldAnchorsObjectsMapToDisk() {
        persistenceManager.saveWorldAnchorsObjectsMapToDisk()
    }
    
    @MainActor
    func addPlacementTooltip(_ tooltip: Entity) {
        placementTooltip = tooltip
        
        // Add a tooltip 10 centimeters in front of the placement location to give
        // users feedback about why they can’t currently place an object.
        placementLocation.addChild(tooltip)
        tooltip.position = [0.0, 0.05, 0.1]
    }
    
    func removeHighlightedObject() async {
        if let highlightedObject = placementState.highlightedObject {
            await persistenceManager.removeObject(highlightedObject)
        }
    }

    @MainActor
    func runARKitSession() async {
        do {
            // Run a new set of providers every time when entering the immersive space.
            try await appState?.arkitSession.run([worldTracking, handTracking, planeDetection])
        } catch {
            // No need to handle the error here; the app is already monitoring the
            // session for error.
            return
        }
    }

    @MainActor
    func collisionBegan(_ event: CollisionEvents.Began) {
        guard let selectedObject = placementState.selectedObject else { return }
        guard selectedObject.matchesCollisionEvent(event: event) else { return }

        placementState.activeCollisions += 1
    }
    
    @MainActor
    func collisionEnded(_ event: CollisionEvents.Ended) {
        guard let selectedObject = placementState.selectedObject else { return }
        guard selectedObject.matchesCollisionEvent(event: event) else { return }
        guard placementState.activeCollisions > 0 else {
            print("Received a collision ended event without a corresponding collision start event.")
            return
        }

        placementState.activeCollisions -= 1
    }
    
    @MainActor
    func select(_ object: PlaceableObject?) {
        if let oldSelection = placementState.selectedObject {
            // Remove the current preview entity.
            placementLocation.removeChild(oldSelection.previewEntity)

            // Handle deselection. Selecting the same object again in the app deselects it.
            if oldSelection.descriptor.fileName == object?.descriptor.fileName {
                select(nil)
                return
            }
        }
        
        // Update state.
        placementState.selectedObject = object
        appState?.selectedFileName = object?.descriptor.fileName
        
        if let object {
            // Add new preview entity.
            placementLocation.addChild(object.previewEntity)
        }
    }
    
    @MainActor
    func processWorldAnchorUpdates() async {
        for await anchorUpdate in worldTracking.anchorUpdates {
            persistenceManager.process(anchorUpdate)
        }
    }
    
    @MainActor
    func processDeviceAnchorUpdates() async {
        await run(function: self.queryAndProcessLatestDeviceAnchor, withFrequency: 90)
    }
    
    @MainActor
    private func queryAndProcessLatestDeviceAnchor() async {
        // Device anchors are only available when the provider is running.
        guard worldTracking.state == .running else { return }
        
        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())

        placementState.deviceAnchorPresent = deviceAnchor != nil
        placementState.planeAnchorsPresent = !planeAnchorHandler.planeAnchors.isEmpty
        placementState.selectedObject?.previewEntity.isEnabled = placementState.shouldShowPreview
        
        guard let deviceAnchor, deviceAnchor.isTracked else { return }
        
        guard let handAnchor = handTracking.latestAnchors.rightHand, handAnchor.isTracked else {
            return
        }
        
        let rightHandAnchorTransform = handAnchor.originFromAnchorTransform
        
//        await updateUserFacingUIOrientations(deviceAnchor)
//        await checkWhichObjectDeviceIsPointingAt(deviceAnchor)
        await updatePlacementLocation(deviceAnchor, offsetsTransform: rightHandAnchorTransform )
    }
    
    @MainActor
    private func updateUserFacingUIOrientations(_ deviceAnchor: DeviceAnchor) async {
        // 1. Orient the front side of the highlighted object’s UI to face the user.
        if let uiOrigin = placementState.highlightedObject?.uiOrigin {
            // Set the UI to face the user (on the y-axis only).
            uiOrigin.look(at: deviceAnchor.originFromAnchorTransform.translation)
            let uiRotationOnYAxis = uiOrigin.transformMatrix(relativeTo: nil).gravityAligned.rotation
            uiOrigin.setOrientation(uiRotationOnYAxis, relativeTo: nil)
        }
        
        // 2. Orient each UI element to face the user.
        for entity in [placementTooltip, dragTooltip, deleteButton] {
            if let entity {
                entity.look(at: deviceAnchor.originFromAnchorTransform.translation)
            }
        }
    }
    
    @MainActor
    private func updatePlacementLocation(_ deviceAnchor: DeviceAnchor, offsetsTransform:simd_float4x4) async {
        let translation = Transform(translation: SIMD3<Float>(-0.5,0,0))
        placementLocation.transform = Transform(matrix: offsetsTransform.gravityAligned * translation.matrix )
        placementState.planeToProjectOnFound = false
    }
    
    @MainActor
    private func checkWhichObjectDeviceIsPointingAt(_ deviceAnchor: DeviceAnchor) async {
        let origin: SIMD3<Float> = raycastOrigin.transformMatrix(relativeTo: nil).translation
        let direction: SIMD3<Float> = -raycastOrigin.transformMatrix(relativeTo: nil).zAxis
        let collisionMask = PlacedObject.collisionGroup
        
        if let result = rootEntity.scene?.raycast(origin: origin, direction: direction, query: .nearest, mask: collisionMask).first {
            if let pointedAtObject = persistenceManager.object(for: result.entity) {
                setHighlightedObject(pointedAtObject)
            } else {
                setHighlightedObject(nil)
            }
        } else {
            setHighlightedObject(nil)
        }
    }
    
    @MainActor
    func setHighlightedObject(_ objectToHighlight: PlacedObject?) {
        guard placementState.highlightedObject != objectToHighlight else {
            return
        }
        placementState.highlightedObject = objectToHighlight

        // Detach UI from the previously highlighted object.
        guard let deleteButton, let dragTooltip else { return }
        deleteButton.removeFromParent()
        dragTooltip.removeFromParent()

        guard let objectToHighlight else { return }

        // Position and attach the UI to the newly highlighted object.
        let extents = objectToHighlight.extents
        let topLeftCorner: SIMD3<Float> = [-extents.x / 2, (extents.y / 2) + 0.02, 0]
        let frontBottomCenter: SIMD3<Float> = [0, (-extents.y / 2) + 0.04, extents.z / 2 + 0.04]
        deleteButton.position = topLeftCorner
        dragTooltip.position = frontBottomCenter

        objectToHighlight.uiOrigin.addChild(deleteButton)
        deleteButton.scale = 1 / objectToHighlight.scale
        objectToHighlight.uiOrigin.addChild(dragTooltip)
        dragTooltip.scale = 1 / objectToHighlight.scale
    }

    func removeAllPlacedObjects() async {
        await persistenceManager.removeAllPlacedObjects()
    }
    
    func processPlaneDetectionUpdates() async {
        for await anchorUpdate in planeDetection.anchorUpdates {
            await planeAnchorHandler.process(anchorUpdate)
        }
    }
    
    @MainActor
    func placeSelectedObject() {
        // Ensure there’s a placeable object.
        guard let objectToPlace = placementState.objectToPlace else { 
            return
        }

        let object = objectToPlace.materialize(translation: objectToPlace.originTranslation)
        object.position = placementLocation.position
        object.orientation = placementLocation.orientation
        
        Task {
            await persistenceManager.attachObjectToWorldAnchor(object)
        }
        placementState.userPlacedAnObject = true
    }
    
    @MainActor
    func checkIfAnchoredObjectsNeedToBeDetached() async {
        // Check whether objects should be detached from their world anchor.
        // This runs at 10 Hz to ensure that objects are quickly detached from their world anchor
        // as soon as they are moved - otherwise a world anchor update could overwrite the
        // object’s position.
        await run(function: persistenceManager.checkIfAnchoredObjectsNeedToBeDetached, withFrequency: 10)
    }
    
    @MainActor
    func checkIfMovingObjectsCanBeAnchored() async {
        // Check whether objects can be reanchored.
        // This runs at 2 Hz - objects should be reanchored eventually but it’s not time critical.
        await run(function: persistenceManager.checkIfMovingObjectsCanBeAnchored, withFrequency: 2)
    }
    
    @MainActor 
    func updateRotation(value:EntityTargetValue<RotateGesture3D.Value>) {
        if let currentDrag, currentDrag.draggedObject !== value.entity {
            // Make sure any previous drag ends before starting a new one.
            print("A new drag started but the previous one never ended - ending that one now.")
            endDrag()
        }
        
        // At the start of the drag gesture, remember which object is being manipulated.
        if currentDrag == nil {
            guard let object = persistenceManager.object(for: value.entity) else {
                print("Unable to start drag - failed to identify the dragged object.")
                return
            }
            
            object.isBeingDragged = true
            currentDrag = DragState(objectToDrag: object)
            placementState.userDraggedAnObject = true
        }
        
        // Update the dragged object’s position.
        if let currentDrag {
            currentDrag.draggedObject.orientation = currentDrag.initialOrientation.normalized * simd_quatf(real: Float(value.gestureValue.rotation.quaternion.real), imag: SIMD3<Float>(Float(value.gestureValue.rotation.quaternion.imag.x), Float(value.gestureValue.rotation.quaternion.imag.y), Float(value.gestureValue.rotation.quaternion.imag.z)))
        }
    }
    
    @MainActor
    func updateDrag(value: EntityTargetValue<DragGesture.Value>) {
        if let currentDrag, currentDrag.draggedObject !== value.entity {
            // Make sure any previous drag ends before starting a new one.
            print("A new drag started but the previous one never ended - ending that one now.")
            endDrag()
        }
        
        // At the start of the drag gesture, remember which object is being manipulated.
        if currentDrag == nil {
            guard let object = persistenceManager.object(for: value.entity) else {
                print("Unable to start drag - failed to identify the dragged object.")
                return
            }
            
            object.isBeingDragged = true
            currentDrag = DragState(objectToDrag: object)
            placementState.userDraggedAnObject = true
        }
        
        // Update the dragged object’s position.
        if let currentDrag {
            currentDrag.draggedObject.position = currentDrag.initialPosition + value.convert(value.translation3D, from: .local, to: rootEntity)
//            // If possible, snap the dragged object to a nearby horizontal plane.
//            let maxDistance = ARSessionManager.snapToPlaneDistanceForDraggedObjects
//            if let projectedTransform = PlaneProjector.project(point: currentDrag.draggedObject.transform.matrix,
//                                                               ontoHorizontalPlaneIn: planeAnchorHandler.planeAnchors,
//                                                               withMaxDistance: maxDistance) {
//                currentDrag.draggedObject.position = projectedTransform.translation
//            }
        }
    }
    
    @MainActor
    func endDrag() {
        guard let currentDrag else { return }
        currentDrag.draggedObject.isBeingDragged = false
        self.currentDrag = nil
    }
}

extension ARSessionManager {
    /// Run a given function at an approximate frequency.
    ///
    /// > Note: This method doesn’t take into account the time it takes to run the given function itself.
    @MainActor
    func run(function: () async -> Void, withFrequency hz: UInt64) async {
        while true {
            if Task.isCancelled {
                return
            }
            
            // Sleep for 1 s / hz before calling the function.
            let nanoSecondsToSleep: UInt64 = NSEC_PER_SEC / hz
            do {
                try await Task.sleep(nanoseconds: nanoSecondsToSleep)
            } catch {
                // Sleep fails when the Task is cancelled. Exit the loop.
                return
            }
            
            await function()
        }
    }
}
