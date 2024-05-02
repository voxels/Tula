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

    @State private var showCheckout = true
    @Binding public var shopifyModel:ShopifyModel
    public let model:ModelViewContent
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var placementModel:ModelViewContent?
    @Binding public var currentIndex:Int
    @State public var checkoutAttachmentEntity:ViewAttachmentEntity?
    @State public var indicatorAttachmentEntity:ViewAttachmentEntity?
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
            RealityView { scene, attachments in
                resetState(for: scene, attachments: attachments)
            } update: {  scene, attachments in
                if flowerEntity.name != model.usdzModelName {
                    resetState(for: scene, attachments: attachments)
                }
                if !showCheckout && checkoutAttachmentEntity != nil {
                    resetState(for: scene, attachments: attachments)
                }
                if checkoutAttachmentEntity == nil,flowerEntity.name == model.usdzModelName, showCheckout {
                    resetState(for: scene, attachments: attachments)
                }
            } attachments: {
                Attachment(id:"back") {
                    Button {
                        scroll(to: currentIndex - 1)
                    } label: {
                        Label("Checkout", systemImage: "chevron.left")
                    }.labelStyle(.iconOnly)
                }
                Attachment(id:"forward") {
                    Button {
                        scroll(to:currentIndex + 1)
                    } label: {
                        Label("Checkout", systemImage: "chevron.right")
                    }.labelStyle(.iconOnly)
                }
                Attachment(id: "indicator") {
                    Button {
                        showCheckout.toggle()
                    } label: {
                        Label("Checkout", systemImage: showCheckout ? "xmark" : "checkmark")
                    }.labelStyle(.iconOnly)
                }
                Attachment(id: "label") {
                    ZStack(content: {
                        RoundedRectangle(cornerRadius: 30).foregroundStyle(.thinMaterial)
                        VStack(alignment: .leading, content: {
                            HStack {
                                if let featuredImage = model.featuredImage {
                                    AsyncImage(url:featuredImage.url)
                                        .frame(width:108, height:136)
                                        .cornerRadius(15)
                                        .padding(.vertical, 8)
                                        .padding(.leading, 24)

                                } else if let featuredImage = model.localImages.first {
                                    Image(featuredImage)
                                        .resizable()
                                        .frame(width:108, height:136)
                                        .cornerRadius(15)
                                        .padding(.vertical,8)
                                        .padding(.leading, 24)
                                }
                                VStack(alignment: .leading, spacing: 0){
                                    Spacer()
                                    Text(model.title).bold().padding(4)
                                    if let firstVariant = model.variantPrices.first {
                                        HStack{
                                            Text(firstVariant.title).padding(4)
                                            let price = NSDecimalNumber(decimal: firstVariant.amount).doubleValue
                                            Text("\(price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))").padding(4)
                                            
                                        }
                                    }
                                    Spacer()
                                    HStack {
                                        Button{
                                            
                                        } label: {
                                            Label("Add", systemImage: "cart.badge.plus")
                                        }
                                        .padding(4)
                                        PaymentButton().frame(width: 486/3, height:60)
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                        })
                        
                    })
                    .frame(maxWidth:480, maxHeight:184)
                }
                
            }
            .onChange(of: toyTransform) { oldValue, newValue in
                let newRotation = toyTransform.rotation
                let newTransform = Transform(scale: flowerEntity.transform.scale, rotation:newRotation, translation:flowerEntity.transform.translation)
                flowerEntity.transform = newTransform
            }
            .gesture(
                ExclusiveGesture(
                TapGesture().targetedToEntity(flowerEntity).onEnded({ _ in
                    showCheckout.toggle()
                }),
                    DragGesture()
                    .targetedToEntity(flowerEntity)
                    .onChanged({ value in
                    let width = value.translation.width
                    let height = value.translation.height
                    print(width)
                    let xAngle = Angle(degrees: width)
                    let xRotation = simd_quatf(angle: Float(xAngle.radians), axis: SIMD3(0,1,0))
                    let rotation = xRotation
                    let transform = Transform(scale:SIMD3(1,1,1), rotation:rotation, translation:SIMD3.zero)
                    toyTransform = transform
                    })
                )
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
                
                checkoutAttachmentEntity?.removeFromParent()
                checkoutAttachmentEntity = nil
                        
                if flowerEntity.parent == nil || (flowerEntity.parent != nil && flowerEntity.name != model.usdzModelName)  {
                    flowerEntity = try await Entity(named: model.usdzModelName, in:realityKitContentBundle)

                    print("adding flower entity")
                    flowerEntity.name = model.usdzModelName
                                    
                    flowerEntity.generateCollisionShapes(recursive: true)
                    flowerEntity.components.set(InputTargetComponent())
                    flowerEntity.setPosition(SIMD3(0,-0.35,0), relativeTo:nil)
                    flowerEntity.setScale(SIMD3(1,1,1), relativeTo: nil)
                    
                    guard let env = try? await EnvironmentResource(named: "ImageBasedLight")
                    else { return }
                    
                    let iblComponent = ImageBasedLightComponent(source: .single(env),
                                                                intensityExponent: 1)
                    
                    flowerEntity.components[ImageBasedLightComponent.self] = iblComponent
                    flowerEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: flowerEntity))

                    scene.entities.removeAll()
                    scene.add(flowerEntity)
                }
            } catch {
                print(error)
            }
            
            if let label = attachments.entity(for: "label"), showCheckout {
                label.setPosition(SIMD3(0,-0.425,0.2), relativeTo: nil)
                checkoutAttachmentEntity = label
                scene.add(label)
            }
            
            if let forward = attachments.entity(for: "forward"), showCheckout {
                forward.setPosition(SIMD3(0.21,0, 0), relativeTo: checkoutAttachmentEntity!)
                checkoutAttachmentEntity?.addChild(forward)
            }
            
            if let back = attachments.entity(for: "back"), showCheckout {
                back.setPosition(SIMD3(-0.21,0, 0), relativeTo: checkoutAttachmentEntity!)
                checkoutAttachmentEntity?.addChild(back)
            }
        }
    }
    
    private func scroll(to index: Int) {
        if index == modelContent.count  {
            currentIndex = 0
        } else if index == -1 {
            currentIndex = modelContent.count - 1
        } else {
            currentIndex = index.clamped(to: 0..<modelContent.count) // Adjust clamping range
        }
    }
}

#Preview {
    return VolumeView(appState: .constant(TulaAppModel()), modelLoader: .constant(ModelLoader()), shopifyModel: .constant(ShopifyModel()), model: TulaApp.defaultContent.first!, modelContent: .constant(TulaApp.defaultContent), placementModel: .constant(nil), currentIndex: .constant(0))
}
