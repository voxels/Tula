//
//  ImmersiveView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 1/26/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
struct ImmersiveView: View {
    @Binding public var appState: TulaAppModel
    @Binding public var modelLoader: ModelLoader
    @Binding public var placementManager:ARSessionManager
    @Binding public var selectedModel:ModelViewContent?
    @Binding public var placementModel:ModelViewContent?
    @State private var collisionBeganSubscription: EventSubscription? = nil
    @State private var collisionEndedSubscription: EventSubscription? = nil
    
    var body: some View {
        RealityView { content in
                content.add(placementManager.rootEntity)
               
            collisionBeganSubscription = content.subscribe(to: CollisionEvents.Began.self) {  [weak placementManager] event in
                placementManager?.collisionBegan(event)
            }
            
            collisionEndedSubscription = content.subscribe(to: CollisionEvents.Ended.self) {  [weak placementManager] event in
                placementManager?.collisionEnded(event)
            }
        } update: { update in
            let placementState = placementManager.placementState


            if let selectedObject = placementState.selectedObject {
                selectedObject.isPreviewActive = placementState.isPlacementPossible
            }
        }
        .task{
            placementManager.appState = appState
                // Run the ARKit session after the user opens the immersive space.
                await placementManager.runARKitSession()
        }
        .task {
            // Monitor ARKit anchor updates once the user opens the immersive space.
            //
            // Tasks attached to a view automatically receive a cancellation
            // signal when the user dismisses the view. This ensures that
            // loops that await anchor updates from the ARKit data providers
            // immediately end.
            await placementManager.processWorldAnchorUpdates()
        }
        .task {
            await placementManager.processDeviceAnchorUpdates()
        }
        .task {
            await placementManager.processPlaneDetectionUpdates()
        }
        .task {
            await placementManager.checkIfAnchoredObjectsNeedToBeDetached()
        }
        .task {
            await placementManager.checkIfMovingObjectsCanBeAnchored()
        }.task {
            if let selectedModel = selectedModel {
                appState.placementManager?.select(appState.placeableObjectsByFileName[selectedModel.usdzModelName])
            }
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { event in
            // Place the currently selected object when the user looks directly at the selected object’s preview.
            if event.entity.components[CollisionComponent.self]?.filter.group == PlaceableObject.previewCollisionGroup {
                placementManager.placeSelectedObject()
            }
        })
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .handActivationBehavior(.pinch) // Prevent moving objects by direct touch.
            .onChanged { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedObject.collisionGroup {
                    placementManager.updateDrag(value: value)
                }
            }
            .onEnded { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedObject.collisionGroup {
                    placementManager.endDrag()
                }
            }
        )
        .gesture(RotateGesture3D(constrainedToAxis: .y, minimumAngleDelta: Angle(degrees: 1)).targetedToAnyEntity().onChanged({ value in
            if value.entity.components[CollisionComponent.self]?.filter.group == PlacedObject.collisionGroup {
                placementManager.updateRotation(value: value)
            }
        }))
        .onAppear(perform: {
            appState.immersiveSpaceOpened(with: placementManager)
        })
        .onDisappear() {
            print("Leaving immersive space.")
            appState.didLeaveImmersiveSpace()
        }
        
        .onChange(of: selectedModel) { oldValue, newValue in
            if let selectedModel = newValue {
                appState.placementManager?.select(appState.placeableObjectsByFileName[selectedModel.usdzModelName])
            } else {
                appState.placementManager?.select(nil)
            }
        }
    }
}

