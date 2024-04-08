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
            DetailItemView(appState: $appState, modelContent: $modelContent, content: $content, playerModel: $playerModel, currentIndex:$currentIndex)
                .frame(minWidth:1400,maxWidth:1400, minHeight: 800, maxHeight:800)
                .onDisappear(perform: {
                    showItemView = false
                })
        } else {
            ScrollView(.horizontal) {
                LazyHStack{
                    ForEach(modelContent) { thisContent in
                        VStack(spacing:0) {
                            if let featuredImage = thisContent.featuredImage {
                                AsyncImage(url:featuredImage.url){ image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height:460)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width:460, height:460)
                                }
                            } else if let firstImage = thisContent.imagesData.first {
                                AsyncImage(url:firstImage.url){ image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height:460)
                                } placeholder: {
                                    ProgressView()                                        .frame(width:460, height:460)

                                }
                            } else if let firstImageName = thisContent.localImages.first {
                                Image(firstImageName)                                        .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height:460)
                            } else {
                                ContentUnavailableView(thisContent.title, systemImage: "gobackward")
                            }
                            ZStack(alignment: .center){
                                Rectangle().foregroundStyle(.thinMaterial)
                                VStack(alignment: .leading, spacing: 0){
                                    Text(thisContent.title)
                                        .multilineTextAlignment(.leading)
                                        .font(.headline)
                                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                    if let price = thisContent.variantPrices.first?.amount {
                                        Text("from \(price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))")
                                            .multilineTextAlignment(.leading)
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
            .scrollIndicators(.hidden)
            .padding(EdgeInsets(top: 0, leading: 16, bottom:0, trailing: 0))
        }
    }
}

#Preview {
    GalleryView(collectionID: UUID(), appState:.constant(TulaAppModel()), shopifyModel: .constant(ShopifyModel()), modelContent: .constant(TulaApp.defaultContent), content: .constant(TulaApp.defaultContent.first!), playerModel: .constant(PlayerModel()), placementModel: .constant(TulaApp.defaultContent.first!), showImmersiveTab: .constant(false), selectedTab: .constant(0), currentIndex: .constant(0))
}
