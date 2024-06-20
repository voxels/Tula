//
//  PlaceableObject.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/9/24.
//


import Foundation
import RealityKit

public struct ModelDescriptor: Identifiable, Hashable {
    let fileName: String
    let displayName: String

    public var id: String { fileName }

    init(fileName: String, displayName: String? = nil) {
        self.fileName = fileName
        self.displayName = displayName ?? fileName
    }
}

private enum PreviewMaterials {
    static let active = UnlitMaterial(color: .gray.withAlphaComponent(0.5))
    static let inactive = UnlitMaterial(color: .gray.withAlphaComponent(0.1))
}

@MainActor
public class PlaceableObject {
    let descriptor: ModelDescriptor
    var previewEntity: Entity
    var renderContent: ModelEntity
    public var originTranslation:SIMD3<Float>
    
    static let previewCollisionGroup = CollisionGroup(rawValue: 1 << 15)
    
    init(descriptor: ModelDescriptor, renderContent: ModelEntity, previewEntity: Entity, originTranslation:SIMD3<Float>) {
        self.descriptor = descriptor
        self.previewEntity = previewEntity
//        self.previewEntity.applyMaterial(PreviewMaterials.active)
        self.renderContent = renderContent
        self.originTranslation = originTranslation
    }

    var isPreviewActive: Bool = true {
        didSet {
            if oldValue != isPreviewActive {
//                previewEntity.applyMaterial(isPreviewActive ? PreviewMaterials.active : PreviewMaterials.inactive)
                // Only act as input target while active to prevent intercepting drag gestures from intersecting placed objects.
                previewEntity.components[InputTargetComponent.self]?.allowedInputTypes = isPreviewActive ? .indirect : []
            }
        }
    }

    func materialize(translation:SIMD3<Float>) -> PlacedObject {
        let shapes = previewEntity.components[CollisionComponent.self]!.shapes
        return PlacedObject(descriptor: descriptor, renderContentToClone: renderContent, shapes: shapes, translation: translation)
    }

    func matchesCollisionEvent(event: CollisionEvents.Began) -> Bool {
        event.entityA == previewEntity || event.entityB == previewEntity
    }

    func matchesCollisionEvent(event: CollisionEvents.Ended) -> Bool {
        event.entityA == previewEntity || event.entityB == previewEntity
    }

    func attachPreviewEntity(to entity: Entity) {
        entity.addChild(previewEntity)
    }
}

class PlacedObject: Entity {
    let fileName: String
    
    // The 3D model displayed for this object.
    private let renderContent: ModelEntity

    static let collisionGroup = CollisionGroup(rawValue: 1 << 29)
    
    // The origin of the UI attached to this object.
    // The UI is gravity aligned and oriented towards the user.
    let uiOrigin = Entity()
    
    var affectedByPhysics = false {
        didSet {
            guard affectedByPhysics != oldValue else { return }
            if affectedByPhysics {
                components[PhysicsBodyComponent.self]!.mode = .dynamic
            } else {
                components[PhysicsBodyComponent.self]!.mode = .static
            }
        }
    }
    
    var isBeingDragged = false {
        didSet {
            affectedByPhysics = !isBeingDragged
        }
    }
    
    var positionAtLastReanchoringCheck: SIMD3<Float>?
    
    var atRest = false

    init(descriptor: ModelDescriptor, renderContentToClone: ModelEntity, shapes: [ShapeResource], translation:SIMD3<Float>) {
        fileName = descriptor.fileName
        renderContent = renderContentToClone.clone(recursive: true)
        renderContent.transform.translation = translation
        super.init()
        name = renderContent.name
        
        // Apply the rendered content’s scale to this parent entity to ensure
        // that the scale of the collision shape and physics body are correct.
        scale = renderContent.scale
        renderContent.scale = .one
        
        // Make the object respond to gravity.
        let physicsMaterial = PhysicsMaterialResource.generate(restitution: 0.0)
        let physicsBodyComponent = PhysicsBodyComponent(shapes: shapes, mass: 1.0, material: physicsMaterial, mode: .static)
        components.set(physicsBodyComponent)
        components.set(CollisionComponent(shapes: shapes, isStatic: false,
                                          filter: CollisionFilter(group: PlacedObject.collisionGroup, mask: .all)))
        addChild(renderContent)
        addChild(uiOrigin)
        uiOrigin.position.y = extents.y / 2 // Position the UI origin in the object’s center.
        
        // Allow direct and indirect manipulation of placed objects.
        components.set(InputTargetComponent(allowedInputTypes: [.direct, .indirect]))
        
        // Add a grounding shadow to placed objects.
        renderContent.components.set(GroundingShadowComponent(castsShadow: true))
    }
    
    required init() {
        fatalError("`init` is unimplemented.")
    }
}

extension Entity {
    func applyMaterial(_ material: Material) {
        if let modelEntity = self as? ModelEntity {
            modelEntity.model?.materials = [material]
        }
        for child in children {
            child.applyMaterial(material)
        }
    }

    var extents: SIMD3<Float> { visualBounds(relativeTo: self).extents }

    func look(at target: SIMD3<Float>) {
        look(at: target,
             from: position(relativeTo: nil),
             relativeTo: nil,
             forward: .positiveZ)
    }
}

