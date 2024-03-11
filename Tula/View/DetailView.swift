//
//  DetailView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/15/24.
//

import SwiftUI

struct DetailView: View {
    let appState: TulaAppModel
    @Binding public var shopifyModel:ShopifyModel
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var content:ModelViewContent?
    
    @Binding public var placementModel:ModelViewContent?
    @State private var showImmersiveTab = false
    @State private var selectedTab = 0
    var body: some View {
            TabView(selection: $selectedTab,
                    content:  {
                VStack(alignment: .center, spacing:0) {
                    Image("Tula-House-Logo-White@4x")
                        .resizable()
                        .frame(width: 96, height: 60, alignment: .center)
                        .padding(EdgeInsets(top: 60, leading: 0, bottom: 0, trailing: 0))
                    ScrollView(.horizontal) {
                        LazyHStack{
                            ForEach(modelContent) { content in
                                VStack(spacing:0) {
                                    Image(content.image1URLString).resizable().aspectRatio(contentMode: .fill)
                                        .frame(height:460)
                                    ZStack(alignment: .center){
                                        Rectangle().foregroundStyle(.thinMaterial)
                                        VStack(alignment: .leading, spacing: 0){
                                            Text(content.title)
                                                .multilineTextAlignment(.leading)
                                                .font(.headline)
                                                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                            if let price = content.smallPrice {
                                                Text("from \(price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))")
                                                    .multilineTextAlignment(.leading)
                                                    .font(.subheadline)
                                                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                                            }
                                        }
                                    }.frame(height:116)
                                }
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 32,
                                        bottomLeadingRadius: 32,
                                        bottomTrailingRadius: 32,
                                        topTrailingRadius: 32
                                    )
                                ).onTapGesture {
                                    self.content = content
                                    selectedTab = 1
                                }
                                .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                .hoverEffect(.automatic)
                            }
                        }
                        
                    }
                    .scrollIndicators(.hidden)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom:0, trailing: 0))
                }
                .frame(minWidth:1280,maxWidth:1280)
                .tabItem { Label("Gallery", systemImage: "tree")}
                .tag(0)
                DetailItemView(appState: appState, modelContent: $modelContent, content: $content)
                    .frame(minWidth:1280,maxWidth:1280, minHeight: 800, maxHeight:800)
                    .tabItem { Label("Plants", systemImage: "leaf")}
                    .tag(1)
                DetailCartView(shopifyModel: $shopifyModel)
                    .tabItem { Label("Cart", systemImage: "cart") }
                    .frame(minWidth:1280,maxWidth:1280, minHeight: 800, maxHeight:800)
                    .tag(2)
                if showImmersiveTab {
                    ImmersiveIntroView(appState: appState, content: $content, placementModel: $placementModel).tabItem { Label("Immersive", systemImage: "visionpro")  }.tag(3)
                }
            })
            .glassBackgroundEffect()
            .frame(minWidth:1280,maxWidth:1280, minHeight: 800, maxHeight:800)
            .onChange(of: selectedTab) { oldValue, newValue in
                content = nil
            }
    }
}

#Preview {
    DetailView(appState: TulaAppModel(), shopifyModel: .constant(ShopifyModel()), modelContent: .constant(TulaApp.defaultContent), content:.constant( nil), placementModel: .constant(nil))
}
