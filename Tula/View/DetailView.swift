//
//  DetailView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/15/24.
//

import SwiftUI

struct DetailView: View {
    @Binding public var appState: TulaAppModel
    @Binding public var modelLoader: ModelLoader
    @Binding public var shopifyModel:ShopifyModel
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var content:ModelViewContent?
    @Binding public var playerModel:PlayerModel
    @Binding public var placementModel:ModelViewContent?
    @State private var showImmersiveTab = false
    @State private var selectedTab = 0
    @State private var currentIndex = 0
    var body: some View {
        if shopifyModel.collectionResponses.count > 0 {
            let count:Int = shopifyModel.collectionResponses.count
            TabView(selection: $selectedTab,
                    content:  {
                    ForEach(0..<count, id:\.self) { index in
                        let collectionResponse = shopifyModel.collectionResponses[index]
                        let collectionTitle = collectionResponse.collection.title
                        GalleryView(collectionID: collectionResponse.id, appState:$appState, shopifyModel: $shopifyModel, modelContent: $modelContent, content:$content, playerModel: $playerModel, placementModel: $placementModel, showImmersiveTab: $showImmersiveTab, selectedTab: $selectedTab, currentIndex: $currentIndex)
                            .frame(minWidth:1400,maxWidth:1400, minHeight: 800, maxHeight:800)
                            .tabItem { Label(collectionTitle == "Products" ? "Toys" : collectionTitle, systemImage: systemImageName(for: collectionResponse))}
                            .tag(index)
                    }
                    if showImmersiveTab {
                        ImmersiveIntroView(appState: appState, content: $content, placementModel: $placementModel).tabItem { Label("Purchases", systemImage: "heart.fill")  }.tag(shopifyModel.collectionResponses.count + 1)
                    }
            })
            .glassBackgroundEffect()
            .frame(minWidth:1400,maxWidth:1400, minHeight: 800, maxHeight:800)
            .onChange(of: selectedTab) { oldValue, newValue in
                let collectionResponses = shopifyModel.collectionResponses
                if newValue < collectionResponses.count {
                    let collection = collectionResponses[newValue]
                    modelContent = shopifyModel.modelViewContent(for: collection.collection.id.rawValue)
                }
            }
            
        } else {
            TabView(selection: $selectedTab,
                    content:  {
                    let count = 1
                    ForEach(0..<count, id:\.self) { index in
                        let collectionTitle = "Gallery"
                        GalleryView(collectionID: UUID(), appState:$appState, shopifyModel: $shopifyModel, modelContent: $modelContent, content:$content, playerModel: $playerModel, placementModel: $placementModel, showImmersiveTab: $showImmersiveTab, selectedTab: $selectedTab, currentIndex: $currentIndex)
                            .frame(minWidth:1400,maxWidth:1400, minHeight: 800, maxHeight:800)
                            .tabItem { Label(collectionTitle, systemImage:"tree")}
                            .tag(index)
                    }
                    if showImmersiveTab {
                        ImmersiveIntroView(appState: appState, content: $content, placementModel: $placementModel).tabItem { Label("Purchases", systemImage: "heart.fill")  }.tag(shopifyModel.collectionResponses.count + 1)
                    }
            })
            .glassBackgroundEffect()
            .frame(minWidth:1400,maxWidth:1400, minHeight: 800, maxHeight:800)
            .onChange(of: selectedTab) { oldValue, newValue in
                let collectionResponses = shopifyModel.collectionResponses
                if newValue < collectionResponses.count {
                    let collection = collectionResponses[newValue]
                    modelContent = shopifyModel.modelViewContent(for: collection.collection.id.rawValue)
                }
            }
        }
    }
    
    func systemImageName(for collection:ShopifyCollectionResponse)->String {
        switch collection.collection.id.rawValue {
        default:
            return "leaf"
        }
    }
}

#Preview {
    DetailView(appState: .constant( TulaAppModel()), modelLoader: .constant(ModelLoader()), shopifyModel: .constant(ShopifyModel()), modelContent: .constant(TulaApp.defaultContent), content:.constant( nil), playerModel: .constant(PlayerModel()), placementModel: .constant(nil))
}
