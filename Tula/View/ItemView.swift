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
    let appState: TulaAppModel
    @Binding public var content:ModelViewContent
    @Binding public var showVideo:Bool
    @State private var selectedPrice:Float = 0
    @State private var quantity:Int = 0
    @State private var flowerModelAnchorEntity:Entity?
    @State private var flowerModelEntity:Entity?
    @State private var countFrames:Double = 0
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    var body: some View {
        if !showVideo {
            
            GeometryReader(content: { geo in
                VStack(alignment: .center, spacing:0, content: {
                    Text(content.title).font(.largeTitle)
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    HStack(alignment:.center, spacing:0, content: {
                        VStack(spacing:0){
                            ScrollViewReader(content: { scrollViewProxy in
                                
                            ScrollView(.horizontal){
                                HStack(alignment:.center,spacing:0) {
                                    Image(content.image1URLString)
                                        .resizable()
                                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                        .cornerRadius(30)
                                        .frame(maxWidth:  (geo.size.width / 3 - 48))
                                        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 30,
                                                bottomLeadingRadius: 30,
                                                bottomTrailingRadius: 30,
                                                topTrailingRadius: 30
                                            )
                                        ).id(0)
                                    Image(content.image2URLString)
                                        .resizable()
                                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                        .cornerRadius(30)
                                        .frame(maxWidth:  (geo.size.width / 3 - 48))
                                        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 30,
                                                bottomLeadingRadius: 30,
                                                bottomTrailingRadius: 30,
                                                topTrailingRadius: 30
                                            )
                                        ).id(1)
                                    Image(content.image3URLString)
                                        .resizable()
                                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                        .cornerRadius(30)
                                        .frame(maxWidth:  (geo.size.width / 3 - 48))
                                        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 30,
                                                bottomLeadingRadius: 30,
                                                bottomTrailingRadius: 30,
                                                topTrailingRadius: 30
                                            )
                                        ).id(2)
                                    if let image4URLString = content.image4URLString {
                                        Image(image4URLString)
                                            .resizable()
                                            .aspectRatio(contentMode:.fill)
                                            .cornerRadius(30)
                                            .frame(maxWidth:  (geo.size.width / 3 - 48))
                                            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .clipShape(
                                                .rect(
                                                    topLeadingRadius: 30,
                                                    bottomLeadingRadius: 30,
                                                    bottomTrailingRadius: 30,
                                                    topTrailingRadius: 30
                                                )
                                            ).id(3)
                                    }
                                }
                            }.scrollTargetBehavior(.paging)
                            HStack {
                                Image(content.image1URLString).resizable()
                                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                    .frame(maxWidth:  (geo.size.width / 3 - 48) / 4)
                                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .hoverEffect()
                                    .cornerRadius(16)
                                
                                    .onTapGesture {
                                        scrollViewProxy.scrollTo(0, anchor: .center)
                                    }
                                Image(content.image2URLString).resizable()
                                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                    .frame(maxWidth:  (geo.size.width / 3 - 48) / 4)
                                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .hoverEffect()
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        scrollViewProxy.scrollTo(1, anchor: .center)
                                    }
                                Image(content.image3URLString).resizable()
                                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                    .frame(maxWidth:  (geo.size.width / 3 - 48) / 4)
                                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .hoverEffect()
                                    .cornerRadius(16)
                                    .onTapGesture {
                                        scrollViewProxy.scrollTo(2, anchor: .center)
                                    }
                                if let imageURLString = content.image4URLString, !imageURLString.isEmpty {
                                    Image(imageURLString).resizable()
                                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                        .frame(maxWidth:(geo.size.width / 3 - 48) / 4)
                                        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .hoverEffect()
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            scrollViewProxy.scrollTo(3, anchor: .center)
                                        }
                                }
                            }
                            .frame(maxHeight:100)
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            })
                        }.padding(24)
                        VStack(alignment: .leading, spacing:8) {
                            HStack {
                                Text("Size:")
                                if let smallPrice = content.smallPrice {
                                    Button("Small") {
                                        selectedPrice = smallPrice
                                    }
                                }
                                if let largePrice = content.largePrice {
                                    Button("Large") {
                                        selectedPrice = largePrice
                                    }
                                }
                                if let specimenPrice = content.specimenPrice {
                                    Button("Specimen") {
                                        selectedPrice = specimenPrice
                                    }
                                }
                            }.padding(EdgeInsets(top: 20, leading: 0, bottom: 16, trailing: 0))
                            HStack(content: {
                                Text("\(selectedPrice.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))").bold()
                              Spacer()
                            })
                            HStack(content: {
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
                            })
                            HStack {
                                Button {
                                    
                                } label: {
                                    Label("Add to cart", systemImage: "cart.badge.plus")
                                }
                                PaymentButton().frame(width: 486/3, height:60)
                                
                                
                            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
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
                            RealityView { scene in
                                do {
                                    let entity = try await Entity(named: content.flowerModelName, in:realityKitContentBundle)
                                    entity.position = SIMD3(0, -0.125, 0.15)
                                    entity.setScale(SIMD3(0.4,0.4,0.4), relativeTo: nil)
                                    scene.add(entity)
                                    
                                    guard let env = try? await EnvironmentResource(named: "ImageBasedLight")
                                    else { return }
                                    
                                    let iblComponent = ImageBasedLightComponent(source: .single(env),
                                                                                intensityExponent: 1)
                                    
                                    entity.components[ImageBasedLightComponent.self] = iblComponent
                                    entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
                                    flowerModelEntity = entity
                                    let anchorEntity = Entity()
                                    flowerModelAnchorEntity = anchorEntity
                                    scene.add(flowerModelAnchorEntity!)
                                } catch {
                                    print(error)
                                }
                            }
                            .frame(width: geo.size.width / 3 - 48, height:geo.size.height/2)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 64, trailing: 0))
                            .onChange(of: appState.displayLinkTimestamp) { oldValue, newValue in
                                if let flowerModelEntity = flowerModelEntity {
                                    flowerModelEntity.transform.rotation = simd_quatf(angle:Float(Angle.degrees(countFrames).radians), axis: simd_float3(0,1,0))
                                    countFrames += 0.25
                                }
                            }
                            VStack {
                                Button {
                                    switch content.floorPotModelName {
                                    case "cactus_volume_scene", "cereus_volume_scene", "alocasia_volume_scene":
                                        openWindow(id:"VolumeLargePlantView")
                                    default:
                                        openWindow(id:"VolumeSmallPlantView")
                                    }
                                } label: {
                                    Label("Place in your space", systemImage: "cube.fill")
                                }
                                Button {
                                    openWindow(id: "VideoPlayer")
                                } label: {
                                    Label("Plant care", systemImage: "video.fill")
                                }
                                .padding(16)
                            }
                        }.frame(width: geo.size.width / 3 - 48).padding(24)
                    })
                })
            })
            .task {
                if let smallPrice = content.smallPrice {
                    selectedPrice = smallPrice
                } else if let largePrice = content.largePrice {
                    selectedPrice = largePrice
                } else if let specimenPrice = content.specimenPrice {
                    selectedPrice = specimenPrice
                }
            }
        }
    }
}

#Preview {
    ItemView(appState: TulaAppModel(), content: .constant(TulaApp.defaultContent.first!), showVideo: .constant(false))
}

