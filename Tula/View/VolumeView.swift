//
//  VolumeView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import PassKit

struct VolumeView: View {
    public let appState: TulaAppModel
    public let modelLoader: ModelLoader
    @Binding public var shopifyModel:ShopifyModel
    @Binding public var model:ModelViewContent?
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var placementModel:ModelViewContent?
    @State public var flowerEntity:Entity = Entity()
    var body: some View {
        ZStack {
            if let model = model  {
            RealityView { scene, attachments in
                     resetState(for: scene, attachments: attachments)

                } update: {  scene, attachments in
                    if flowerEntity.name != model.floorPotModelName {
                        flowerEntity.removeFromParent()
                        resetState(for: scene, attachments: attachments)
                    }

                } attachments: {
                    Attachment(id: "label") {
                        ZStack(content: {
                            RoundedRectangle(cornerRadius: 30).foregroundStyle(.thinMaterial)
                            VStack(alignment: .center, content: {
                                HStack {
                                    Image(model.image1URLString)
                                        .resizable()
                                        .frame(width:108, height:136)
                                        .cornerRadius(15)
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
                                    VStack (alignment: .leading){
                                        Text(model.title).bold().padding(4)
                                        HStack{
                                            Text("Specimen")
                                            Spacer()
                                            if let specimenPrice = model.specimenPrice {
                                                Text("\(specimenPrice.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))")
                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                                            }
                                        }
                                        HStack {
                                            Button{
                                                
                                            } label: {
                                                Label("Add to cart", systemImage: "cart.badge.plus")
                                            }
                                            PaymentButton().frame(width: 486/3, height:60)
                                            Spacer()
                                        }
                                    }
                                    
                                }.padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                            })
                        })
                        .glassBackgroundEffect()
                        .frame(maxWidth:512, maxHeight:180)
                    }
                }
                .gesture(
                    SpatialEventGesture()
                        .onChanged { events in
                            for event in events {
                                if event.phase == .active {
                                    // Update particle emitters.
                                    if let rotation = event.targetedEntity?.transform.rotation, let inputPose = event.inputDevicePose {
                                        let changeRotation = simd_quatf(angle: Float(inputPose.pose3D.rotation.inverse.quaternion.angle) + Float.pi, axis: SIMD3<Float>(0,1,0))
                                        flowerEntity.transform.rotation = changeRotation
                                    }
                                }
                            }
                        }
                        .onEnded { events in
                            
                            
                        }
                )
            } else {
                ProgressView("Loading model")
            }
        }
    }
    
    @MainActor
    func resetState(for scene:RealityViewContent, attachments:RealityViewAttachments ) {
        Task { @MainActor in
        guard let model = model else {
            return
        }
        let entity = try await Entity(named: model.floorPotModelName, in:realityKitContentBundle)
        flowerEntity = entity
            flowerEntity.name = model.floorPotModelName
        
        flowerEntity.generateCollisionShapes(recursive: true)
        flowerEntity.components.set(InputTargetComponent())
        
        switch model.floorPotModelName {
        case "cactus_volume_scene", "cereus_volume_scene", "alocasia_volume_scene":
            entity.position.y = -1
        default:
            entity.position.y = -0.35
        }
        
        
        scene.add(entity)
        
        guard let env = try? await EnvironmentResource(named: "ImageBasedLight")
        else { return }
        
        let iblComponent = ImageBasedLightComponent(source: .single(env),
                                                    intensityExponent: 1)
        
        entity.components[ImageBasedLightComponent.self] = iblComponent
        entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
        
        if let attachment = attachments.entity(for: "label") {
            entity.addChild(attachment)
            switch model.floorPotModelName {
            case "cactus_volume_scene", "cereus_volume_scene","alocasia_volume_scene":
                attachment.position = SIMD3(0,1.5, 0.5)
            default:
                attachment.position = SIMD3(0,0, 0.2)
            }
        }
        }
    }
}

#Preview {
    return VolumeView(appState: TulaAppModel(), modelLoader: ModelLoader(), shopifyModel: .constant(ShopifyModel()), model: .constant(TulaApp.defaultContent.first!), modelContent: .constant(TulaApp.defaultContent), placementModel: .constant(nil))
}
