//
//  GalleryView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 3/12/24.
//

import SwiftUI

struct GalleryView: View {
    public let collectionID:UUID
    @Binding public var appState: TulaAppModel
    @Binding public var shopifyModel:ShopifyModel
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var content:ModelViewContent?
    @Binding public var playerModel:PlayerModel
    @Binding public var placementModel:ModelViewContent?
    @Binding public var showImmersiveTab:Bool
    @Binding public var selectedTab:Int
    @Binding public var currentIndex:Int
    @State private var showItemView:Bool = false
    var body: some View {
        if showItemView {
            DetailItemView(appState: $appState, shopifyModel: $shopifyModel, modelContent: $modelContent, content: $content, playerModel: $playerModel, currentIndex:$currentIndex, showItemView: $showItemView)
                .frame(minWidth:1400,maxWidth:1400, minHeight: 800, maxHeight:800)
                .onDisappear(perform: {
                    showItemView = false
                })
        } else {
            ScrollView(.horizontal) {
                LazyHStack(spacing:8){
                    ForEach(modelContent) { thisContent in
                        VStack(spacing:0) {
                            if let featuredImage = thisContent.featuredImage {
                                AsyncImage(url:featuredImage.url){ image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width:386, height:480)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width:386, height:480)
                                }
                            } else if let firstImage = thisContent.imagesData.first {
                                AsyncImage(url:firstImage.url){ image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width:386, height:480)
                                } placeholder: {
                                    ProgressView()                                        .frame(width:386,  height:480)

                                }
                            } else if let firstImageName = thisContent.localImages.first {
                                Image(firstImageName)                                        .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width:386, height:480)
                            } else {
                                ContentUnavailableView(thisContent.title, systemImage: "gobackward")
                            }
                            ZStack(alignment: .center){
                                Rectangle().foregroundStyle(.thinMaterial)
                                VStack(alignment: .center, spacing: 0){
                                    Text(thisContent.title)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth:354)
                                        .font(.headline)
                                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                                    
                                    if let price = thisContent.variantPrices.first?.amount {
                                        Text("from \(price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))")
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth:354)
                                            .font(.subheadline)
                                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                        
                                    } else {
                                        Text("Out of stock")
                                            .font(.subheadline)
                                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                    }
                                }
                            }.frame(height:116)
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 30))
                        .cornerRadius(30)
                        .hoverEffect(.lift)
                        .onTapGesture {
                            currentIndex = modelContent.firstIndex(of: thisContent) ?? 0
                            showItemView.toggle()
                        }
                    }
                }
            }
            .overlay {
                VStack {
                    HStack{
                        Spacer()
                        
                        Image("Tula-House-Logo-White")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight:60)
                            .padding(12)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
            .padding(EdgeInsets(top: 0, leading: 16, bottom:0, trailing: 16))
        }
    }
}

#Preview {
    GalleryView(collectionID: UUID(), appState:.constant(TulaAppModel()), shopifyModel: .constant(ShopifyModel()), modelContent: .constant(TulaApp.defaultContent), content: .constant(TulaApp.defaultContent.first!), playerModel: .constant(PlayerModel()), placementModel: .constant(TulaApp.defaultContent.first!), showImmersiveTab: .constant(false), selectedTab: .constant(0), currentIndex: .constant(0))
}
