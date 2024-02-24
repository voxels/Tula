//
//  DetailView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/15/24.
//

import SwiftUI

struct DetailView: View {
    let appState: TulaAppModel
    public let modelContent:[ModelViewContent]
    @Binding public var content:ModelViewContent?
    
    @Binding public var placementModel:ModelViewContent?
    @State private var showImmersiveTab = false
    @State private var selectedTab = 1
    var body: some View {
        if content == nil {
            TabView(selection: $selectedTab,
                    content:  {
                VStack{
                    Image("Tula-House-Logo-White@4x")
                        .resizable()
                        .frame(width: 96, height: 60, alignment: .center)
                        .padding(20)

                    ScrollView(.horizontal) {
                        LazyHStack{
                            ForEach(modelContent) { content in
                                VStack{
                                    Image(content.image1URLString).resizable().aspectRatio(contentMode: .fill)
                                        .frame(height:460)
                                    ZStack{
                                        Rectangle().foregroundStyle(.thinMaterial)
                                        Text(content.title).multilineTextAlignment(.center)
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
                                    
                                }
                                .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                .hoverEffect(.automatic)
                            }
                        }
                        
                    }
                    .scrollIndicators(.hidden)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                }
                .frame(minWidth:1280,maxWidth:1280)
                .tabItem { Label("Plants", systemImage: "leaf")}
                .tag(1)
                DetailCartView()
                    .tabItem { Label("Cart", systemImage: "cart") }
                    .frame(minWidth:1280,maxWidth:1280, minHeight: 800, maxHeight:800)
                    .tag(2)
                if showImmersiveTab {
                    ImmersiveIntroView(appState: appState, content: $content, placementModel: $placementModel).tabItem { Label("Immersive", systemImage: "visionpro")  }.tag(3)
                }
            })
            .frame(minWidth:1280,maxWidth:1280, minHeight: 800, maxHeight:800)
            .onChange(of: selectedTab) { oldValue, newValue in
                content = nil
            }
        } else  {
            TabView(selection: $selectedTab,
                    content:  {
                DetailItemView(appState: appState, modelContent: modelContent, content: $content)
                    .frame(minWidth:1280,maxWidth:1280, minHeight: 800, maxHeight:800)
                    .tabItem { Label("Plants", systemImage: "leaf")}
                    .tag(1)
                DetailCartView().tabItem { Label("Cart", systemImage: "cart")  }
                    .frame(minWidth:1280,maxWidth:1280, minHeight: 800, maxHeight:800)
                    .tag(2)
                if showImmersiveTab {
                    ImmersiveIntroView(appState: appState, content: $content, placementModel: $placementModel)
                        .tabItem { Label("Immersive", systemImage: "visionpro")  }
                        .tag(3)
                }
            })
            .frame(minWidth:1280,maxWidth:1280, minHeight: 800, maxHeight:800)
            .onChange(of: selectedTab) { oldValue, newValue in
                content = nil
            }
        }
    }
}

#Preview {
    DetailView(appState: TulaAppModel(), modelContent: TulaApp.defaultContent, content:.constant( TulaApp.defaultContent.first!), placementModel: .constant(nil))
}
