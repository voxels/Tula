//
//  ModelLoader.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/9/24.
//

import Foundation
import RealityKit
import RealityKitContent

@MainActor
@Observable
final public class ModelLoader {
    private var didStartLoading = false
    private(set) var progress: Float = 0.0
    private(set) var placeableObjects = [PlaceableObject]()
    private var fileCount: Int = 0
    private var filesLoaded: Int = 0
    
    init(progress: Float? = nil) {
        if let progress {
            self.progress = progress
        }
    }
    
    var didFinishLoading: Bool { progress >= 1.0 }
    
    private func updateProgress() {
        filesLoaded += 1
        if fileCount == 0 {
            progress = 0.0
        } else if filesLoaded == fileCount {
            progress = 1.0
        } else {
            progress = Float(filesLoaded) / Float(fileCount)
        }
    }

    func loadObjects(content:[ModelViewContent]) async {
        // Only allow one loading operation at any given time.
        guard !didStartLoading else { return }
        didStartLoading.toggle()

        fileCount = content.count
        await withTaskGroup(of: Void.self) { group in
            for usdz in content {
                let flowerFileName = usdz.usdzModelName
                let floorPotModelName = usdz.usdzFullSizeModelName
                group.addTask {
                    await self.loadObject(flowerFileName, displayName: usdz.title)
                    await self.updateProgress()
                }
            }
        }
    }
    
    func loadObject(_ fileName: String, displayName:String) async {
        var modelEntity: ModelEntity
        var previewEntity: Entity
        var sceneEntity:Entity
        do {
            // Load the USDZ as a ModelEntity.
            
            try await sceneEntity = Entity(named: fileName, in:realityKitContentBundle)
            
            var mEntity:ModelEntity? = sceneEntity.findEntity(named: "mesh_0") as? ModelEntity
            if mEntity == nil {
                mEntity = sceneEntity.findEntity(named: "node_0") as? ModelEntity
            }
 
            guard let castEntity = mEntity else {
                print("Did not find model entity for \(displayName)")
                print(sceneEntity.children)
                return
            }
            modelEntity = castEntity
            
            // Load the USDZ as a regular Entity for previews.
            previewEntity = sceneEntity.clone(recursive: true)
            previewEntity.name = "Preview of \(modelEntity.name)"
            
            var shape = try await ShapeResource.generateConvex(from: modelEntity.model!.mesh)
            var originTranslation = SIMD3<Float>.zero
            if modelEntity.parent?.transform.translation != SIMD3<Float>.zero {
                originTranslation = modelEntity.parent!.transform.translation
                shape = shape.offsetBy(translation: modelEntity.parent!.transform.translation)
            }
            previewEntity.components.set(CollisionComponent(shapes: [shape], isStatic: false,
                                                            filter: CollisionFilter(group: PlaceableObject.previewCollisionGroup, mask: .all)))

            // Ensure the preview only accepts indirect input (for tap gestures).
            let previewInput = InputTargetComponent(allowedInputTypes: [.indirect])
            previewEntity.components[InputTargetComponent.self] = previewInput
            
            
            guard let env = try? await EnvironmentResource(named: "ImageBasedLight")
            else { return }
            
            let iblComponent = ImageBasedLightComponent(source: .single(env),
                                             intensityExponent: 1)

            modelEntity.components[ImageBasedLightComponent.self] = iblComponent
            modelEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: modelEntity))
        
            let descriptor = ModelDescriptor(fileName: fileName, displayName: displayName)
            placeableObjects.append(PlaceableObject(descriptor: descriptor, renderContent: modelEntity, previewEntity: previewEntity, originTranslation: originTranslation))
        } catch {
            print("Failed to load model \(fileName)")
        }


    }
}

fileprivate extension ModelEntity {
    var displayName: String? {
        !name.isEmpty ? name.replacingOccurrences(of: "_", with: " ") : nil
    }
}
