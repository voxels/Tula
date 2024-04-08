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
    @Binding public var appState: 
    TulaAppModel
    @Binding public var modelLoader: ModelLoader
    @State public var flowerEntity:Entity = Entity()
    @State private var toyTransform:Transform = Transform.identity
    @State private var allowsRotation = true
    @Binding public var shopifyModel:ShopifyModel
    public let model:ModelViewContent
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var placementModel:ModelViewContent?
    var body: some View {
            RealityView { scene, attachments in
                resetState(for: scene, attachments: attachments)
            } update: {  scene, attachments in
                if flowerEntity.name != model.usdzModelName {
                    resetState(for: scene, attachments: attachments)
                }
            } attachments: {
                Attachment(id: "label") {
                    ZStack(content: {
                        RoundedRectangle(cornerRadius: 30).foregroundStyle(.thinMaterial)
                        VStack(alignment: .center, content: {
                            HStack {
                                if let featuredImage = model.featuredImage {
                                    AsyncImage(url:featuredImage.url)
                                        .frame(width:108, height:136)
                                        .cornerRadius(15)

                                } else if let featuredImage = model.localImages.first {
                                    Image(featuredImage)
                                        .resizable()
                                        .frame(width:108, height:136)
                                        .cornerRadius(15)
                                }
                                VStack {
                                    Text(model.title).bold().padding(4)
                                    if let firstVariant = model.variantPrices.first {
                                        HStack{
                                            Text(firstVariant.title)
                                            let price = NSDecimalNumber(decimal: firstVariant.amount).doubleValue
                                            Text("\(price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))")
                                            
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
            .onChange(of: toyTransform) { oldValue, newValue in
                let newRotation = toyTransform.rotation
                let newTransform = Transform(scale: flowerEntity.transform.scale, rotation:newRotation, translation:flowerEntity.transform.translation)
                flowerEntity.transform = newTransform
            }
            .gesture(
                DragGesture()
                    .targetedToEntity(flowerEntity)
                    .onChanged({ value in
                    let width = value.translation.width
                    let height = value.translation.height
                    print(width)
                    let xAngle = Angle(degrees: width)
                    let yAngle = Angle(degrees: height)
                    let xRotation = simd_quatf(angle: Float(xAngle.radians), axis: SIMD3(0,1,0))
                    let rotation = xRotation
                    let transform = Transform(scale:SIMD3(1,1,1), rotation:rotation, translation:SIMD3.zero)
                    toyTransform = transform
                })
            )
        /*
            .gesture(
                SpatialEventGesture()
                    .handActivationBehavior(.pinch)
                    .onChanged { events in
                        for event in events {
                            if event.phase == .active {
                                // Update particle emitters.
                                if let inputPose = event.inputDevicePose {
                                    let transformMatrix = inputPose.pose3D.matrix
                                    let outputMatrix:simd_float4x4 = simd_float4x4(
                                        SIMD4(Float(transformMatrix.columns.0.x),Float(transformMatrix.columns.0.y),Float(transformMatrix.columns.0.z),Float(transformMatrix.columns.0.w)),
                                        SIMD4(Float(transformMatrix.columns.1.x),Float(transformMatrix.columns.1.y),Float(transformMatrix.columns.1.z),Float(transformMatrix.columns.1.w)),
                                        SIMD4(Float(transformMatrix.columns.2.x),Float(transformMatrix.columns.2.y),Float(transformMatrix.columns.2.z),Float(transformMatrix.columns.2.w)),
                                        SIMD4(Float(transformMatrix.columns.3.x),Float(transformMatrix.columns.3.y),Float(transformMatrix.columns.3.z),Float(transformMatrix.columns.3.w)))
                                    toyTransform = Transform(matrix:outputMatrix)
                                }
                            }
                        }
                    }
                    .onEnded { events in
                        print("gesture ended")
                    }
            )
         
         */
    }
    
    
    @MainActor
    func resetState(for scene:RealityViewContent, attachments:RealityViewAttachments){
        print("reset state")

        Task { @MainActor in
            do {
                flowerEntity.removeFromParent()

                flowerEntity = try await Entity(named: model.usdzModelName, in:realityKitContentBundle)
            
                flowerEntity.name = model.usdzModelName
                                
                flowerEntity.generateCollisionShapes(recursive: true)
                flowerEntity.components.set(InputTargetComponent())
                flowerEntity.setPosition(SIMD3(0,-0.15,0), relativeTo:nil)
                flowerEntity.setScale(SIMD3(1,1,1), relativeTo: nil)
                
                guard let env = try? await EnvironmentResource(named: "ImageBasedLight")
                else { return }
                
                let iblComponent = ImageBasedLightComponent(source: .single(env),
                                                            intensityExponent: 1)
                
                flowerEntity.components[ImageBasedLightComponent.self] = iblComponent
                flowerEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: flowerEntity))
                scene.add(flowerEntity)
                
                if let label = attachments.entity(for: "label") {
                    label.setPosition(SIMD3(0,-0.4,0.3), relativeTo: nil)
                    scene.add(label)
                }

            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    return VolumeView(appState: .constant(TulaAppModel()), modelLoader: .constant(ModelLoader()), shopifyModel: .constant(ShopifyModel()), model: TulaApp.defaultContent.first!, modelContent: .constant(TulaApp.defaultContent), placementModel: .constant(nil))
}
