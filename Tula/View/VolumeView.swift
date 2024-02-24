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
    public let modelContent:[ModelViewContent]
    public var model:ModelViewContent
    @Binding public var placementModel:ModelViewContent?
    var body: some View {
            RealityView { scene, attachments in
                do {
                    let entity = try await Entity(named: model.floorPotModelName, in:realityKitContentBundle)
                    
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
                } catch {
                    print(error)
                }
            } update: {  scene, attachments in
                
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
                                VStack {
                                    Text(model.title).bold().padding(4)
                                    HStack{
                                        Text("Specimen")
                                        if let specimenPrice = model.specimenPrice {
                                            Text("\(specimenPrice.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))")
                                        }
                                    }
                                    HStack {
                                        Button{
                                            
                                        } label: {
                                            Label("Add to cart", systemImage: "cart.badge.plus")
                                        }
                                        PaymentButton().frame(width: 486/3, height:60)
                                    }
                                }
                                
                            }.padding(12)
                        })
                    })
                    .frame(maxWidth:486, maxHeight:160)
                }
                
            }
        }
}

#Preview {
    return VolumeView(appState: TulaAppModel(), modelLoader: ModelLoader(), modelContent: TulaApp.defaultContent, model: TulaApp.defaultContent.first!, placementModel: .constant(nil))
}
