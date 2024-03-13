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
    @Binding public var appState: TulaAppModel
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
        GeometryReader(content: { geo in
            VStack(alignment: .center, spacing:0, content: {
                Text(content.title).font(.largeTitle)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                HStack(alignment:.center, spacing:0, content: {
                    VStack(spacing:0){
                        ScrollViewReader(content: { scrollViewProxy in
                            ScrollView(.horizontal){
                                HStack(alignment:.center,spacing:0) {
                                ForEach(0..<content.imagesData.count, id:\.self) { index in
                                    let imageData = content.imagesData[index]
                                    Image(imageData)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(16)
                                        .frame(maxWidth: geo.size.width / 3 - (24 * 2))
                                        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                            }.scrollTargetBehavior(.paging)
                            HStack {
                            ForEach(0..<min(content.imagesData.count, 4), id:\.self) { index in
                                let imageData = content.imagesData[index]
                                Image(imageData)                                            .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame( maxWidth:(geo.size.width / 3 - 48) / 4)
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
                        })
                    }
                        .frame(width: geo.size.width / 3 - 48)
                        .padding(24)
                    VStack(alignment: .leading, spacing:8){
                        HStack(alignment:.center, content: {
                            Text("Price: ")
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
                            Button {
                                
                            } label: {
                                Label("Select size", systemImage:"basket.fill")
                            }
                        }).padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                        HStack(alignment:.center) {
                            Button {
                                
                            } label: {
                                Label("Add to cart", systemImage: "cart.badge.plus")
                            }
                            PaymentButton().frame(width: 486/3, height:60)
                            
                        }.padding(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
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
                                    entity.position = SIMD3(0, -0.125, 0.15)
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
                            .frame(width: geo.size.width / 3 - 48, height:geo.size.height/2)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 120, trailing: 0))
                            .onChange(of: appState.displayLinkTimestamp) { oldValue, newValue in
                                if let flowerModelEntity = flowerModelEntity {
                                    flowerModelEntity.transform.rotation = simd_quatf(angle:Float(Angle.degrees(countFrames).radians), axis: simd_float3(0,1,0))
                                    countFrames += 0.25
                                }
                            }
                            Button {
                                switch content.usdzFullSizeModelName {
                                default:
                                    openWindow(id:"VolumeSmallView")
                                }
                            } label: {
                                Label("Place in your space", systemImage: "cube")
                            }
                        }
                    }.frame(width: geo.size.width / 3 - 48).padding(24)
                })
            })
        })
        .task {
            if let firstVariant = content.variantPrices.first {
                selectedPrice = NSDecimalNumber(decimal:firstVariant.amount).floatValue
            }
        }
    }
}

#Preview {
    ItemView(appState: .constant(TulaAppModel()), content: .constant(TulaApp.defaultContent.first!), showVideo: .constant(false))
}
