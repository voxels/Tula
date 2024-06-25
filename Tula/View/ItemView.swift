//
//  ItemView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/16/24.
//

import SwiftUI
import PassKit
import RealityKit
import RealityKitContent

@MainActor
struct ItemView: View {
    @Environment(\.openURL) var openURL
    @Binding public var appState: TulaAppModel
    @Binding public var shopifyModel:ShopifyModel
    @Binding public var content:ModelViewContent
    @Binding public var playerModel:PlayerModel
    @Binding public var showVideo:Bool
    @State private var selectedPrice:Float = 0
    @State private var selectedVariant:ModelViewContentVariantData?
    @State private var quantity:Int = 0
    @State private var flowerModelAnchorEntity:Entity?
    @State private var flowerModelEntity:Entity?
    @State private var countFrames:Double = 0
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    var body: some View {
        GeometryReader(content: { geo in
            VStack(alignment: .center, spacing:0, content: {
                HStack(alignment:.center, spacing:0, content: {
                    VStack(spacing:0){
                        ScrollViewReader(content: { scrollViewProxy in
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack(alignment:.center,spacing:0) {
                                    if !content.imagesData.isEmpty {
                                        ForEach(0..<content.imagesData.count, id:\.self) { index in
                                            ZStack {
                                            let imageData = content.imagesData[index]
                                            AsyncImage(url:imageData.url){ image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .cornerRadius(16)
                                                    .frame(maxWidth: geo.size.width / 3 - (24 * 2))
                                            } placeholder: {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .frame(maxWidth: geo.size.width / 3 - (24 * 2))
                                                    .foregroundStyle(.thinMaterial)
                                            }.contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                .clipShape(
                                                    .rect(
                                                        topLeadingRadius: 16,
                                                        bottomLeadingRadius: 16,
                                                        bottomTrailingRadius: 16,
                                                        topTrailingRadius: 16
                                                    )
                                                )
                                                .id(index)
                                            }
                                        }
                                    } else {
                                        ForEach(0..<content.localImages.count, id:\.self) { index in
                                            ZStack {
                                                
                                                let imageData = content.localImages[index]
                                                Image(imageData)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .cornerRadius(16)
                                                    .frame(maxWidth: geo.size.width / 3 - (24 * 2)).contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                    .clipShape(
                                                        .rect(
                                                            topLeadingRadius: 16,
                                                            bottomLeadingRadius: 16,
                                                            bottomTrailingRadius: 16,
                                                            topTrailingRadius: 16
                                                        )
                                                    )
                                                    .id(index)
                                            }
                                            
                                        }
                                    }
                                }.scrollTargetLayout()
                            }.scrollTargetBehavior(.paging)
                                .scrollDisabled(true)
                                
                            HStack {
                                if !content.imagesData.isEmpty {
                                    ForEach(0..<min(content.imagesData.count, 4), id:\.self) { index in
                                        let imageData = content.imagesData[index]
                                        AsyncImage(url:imageData.url){ image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame( maxWidth:(geo.size.width / 3 - 48) / 4)
                                                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                .hoverEffect()
                                                .cornerRadius(16)
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 16)
                                                .frame( maxWidth:(geo.size.width / 3 - 48) / 4)
                                                .foregroundStyle(.thinMaterial)
                                        }
                                        .onTapGesture {
                                            scrollViewProxy.scrollTo(index, anchor: .center)
                                        }
                                    }
                                    .frame(maxHeight:100)
                                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                } else {
                                    ForEach(0..<min(content.localImages.count, 4), id:\.self) { index in
                                        let imageData = content.localImages[index]
                                        Image(imageData)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .hoverEffect()
                                            .cornerRadius(16)
                                        .onTapGesture {
                                            scrollViewProxy.scrollTo(index, anchor: .center)
                                        }
                                    }
                                    .frame(maxHeight:100)
                                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                                }
                            }
                        })
                    }
                    .frame(width: geo.size.width / 3 - 48)
                    .padding(.vertical, 24)
                    .padding(.horizontal,16)
                    VStack(alignment: .leading, spacing:0){
                        Text(content.title).font(.largeTitle)
                            .padding(EdgeInsets(top: 32, leading: 0, bottom: 16, trailing: 16))
                        HStack {
                            ForEach(content.variantPrices, id:\.self) { variant in
                                if variant.availableForSale && variant.quantityAvailable > 0 {
                                    Button {
                                        selectedPrice = NSDecimalNumber(decimal:variant.amount).floatValue
                                        selectedVariant = variant
                                    } label: {
                                        Label(variant.title, systemImage:"basket.fill")
                                    }.labelStyle(.titleOnly)
                                }
                            }
                            Spacer()
                        }
                        if !content.variantPrices.isEmpty {
                            HStack(alignment:.center, content: {
                                Text("\(selectedPrice.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))").bold()
                                Spacer()
                            }).padding(EdgeInsets(top: 24, leading: 0, bottom: 16, trailing: 0))
                            HStack(alignment:.center, content: {
                                Text("Quantity")
                                Button("Remove", systemImage: "minus") {
                                    if quantity > 0 {
                                        quantity -= 1
                                    }
                                }.labelStyle(.iconOnly)
                                Text("\(quantity)")
                                Button("Add", systemImage: "plus") {
                                    quantity += 1
                                }.labelStyle(.iconOnly)
                                Spacer()
                            }).padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                            HStack(alignment:.center) {
                                Button {
                                    if let selectedVariant = selectedVariant, quantity > 0 {
                                        shopifyModel.queryCart { cart in
                                            let line = shopifyModel.line(for:selectedVariant.id, quantity: Int32(quantity))
                                            shopifyModel.addCartLines([line]) { cart in
                                                
                                            }
                                        }
                                    }                                } label: {
                                    Label("Add to cart", systemImage: "cart.badge.plus")
                                }
                                Button(action: {
                                    shopifyModel.queryCart { _ in
                                        if let checkoutURL = shopifyModel.checkoutURL {
                                            openURL(checkoutURL)
                                        }
                                    }
                                }, label: {
                                    
                                    Label("Checkout", systemImage: "cart")
                                }).frame(width: 486/3, height:60)
                                
                            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
                        } else {
                            Text("Out of stock")
                                .bold()
                                .padding(.bottom, 24)
                        }
                        ScrollView(.vertical) {
                            Text(content.description)
                                .multilineTextAlignment(.leading)
                        }.statusBarHidden()
                            .mask {
                                VStack(alignment: .center, spacing: 0, content: {
                                    Rectangle().foregroundColor(.black).frame(minHeight:200).padding(0)
                                    Rectangle().foregroundStyle(.black)
                                        .mask(LinearGradient(gradient: Gradient(colors: [.black, .gray, .clear, .clear]), startPoint: .top, endPoint: .bottom)).padding(0)
                                })
                            }
                    }.frame(width: geo.size.width / 3 - 12).padding(6)
                    VStack{
                        if content.usdzModelName.isEmpty {
                            EmptyView()
                        } else {
                            RealityView { scene in
                                do {
                                    let entity = try await Entity(named: content.usdzModelName, in:realityKitContentBundle)
                                    entity.position = SIMD3(0, -0.125, 0.20)
                                    entity.setScale(SIMD3(0.75,0.75,0.75), relativeTo: nil)
                                    entity.generateCollisionShapes(recursive: true)
                                    entity.components.set(InputTargetComponent())
                                    scene.add(entity)
                                    
                                    guard let env = try? await EnvironmentResource(named: "ImageBasedLight")
                                    else { return }
                                    
                                    let iblComponent = ImageBasedLightComponent(source: .single(env),
                                                                                intensityExponent: 1)
                                    
                                    entity.components[ImageBasedLightComponent.self] = iblComponent
                                    entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
                                    flowerModelEntity = entity
                                } catch {
                                    print(error)
                                }
                            }
                            .gesture(SpatialTapGesture(count:1).targetedToAnyEntity().onEnded({ _ in
                                appState.showImmersiveSpace = true
                            }))
                            .frame(width: geo.size.width / 3 - 48, height:geo.size.height/2)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0))
                            .onChange(of: appState.displayLinkTimestamp) { oldValue, newValue in
                                if let flowerModelEntity = flowerModelEntity {
                                    flowerModelEntity.transform.rotation = simd_quatf(angle:Float(Angle.degrees(countFrames).radians), axis: simd_float3(0,1,0))
                                    countFrames += 0.25
                                }
                            }

                            Button {
                                appState.showImmersiveSpace.toggle()
                            } label: {
                                if !appState.showImmersiveSpace {
                                    Label("Place in your space", systemImage: "cube")
                                } else {
                                    Label("Close immersive space", systemImage: "cube")
                                }
                            }.padding(.bottom, 16)
                            Button {
                                showVideo.toggle()
                            } label: {
                                Label("Plant care video", systemImage: "video")
                            }
                        }
                    }.frame(width: geo.size.width / 3 - 48).padding(.vertical,24)
                })
            })
        }).padding(.top, 32)
        .task {
            if let firstVariant = content.variantPrices.first(where: { data in
                data.availableForSale && data.quantityAvailable > 0
            }) {
                selectedVariant = firstVariant
                selectedPrice = NSDecimalNumber(decimal:firstVariant.amount).floatValue
            }
        }
    }
}

#Preview {
    ItemView(appState: .constant(TulaAppModel()), shopifyModel: .constant(ShopifyModel()), content: .constant(TulaApp.defaultContent.first!), playerModel: .constant(PlayerModel()), showVideo: .constant(false))
}
