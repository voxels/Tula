//
//  DetailItemView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/15/24.
//

import SwiftUI

struct DetailItemView: View {
    @Binding public var appState: TulaAppModel
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var content:ModelViewContent?
    @Binding public var playerModel:PlayerModel
    @Binding public var currentIndex:Int
    @Binding public var showItemView:Bool
    @State private var showVideo = false
    var body: some View {
        GeometryReader(content: { geo in
            VStack{
                Spacer()
                ScrollViewReader(content: { scrollViewProxy in
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0, content: {
                            let countObjects = modelContent.count
                            ForEach(0..<countObjects, id: \.self) { index in
                                ItemView(appState: $appState, content: $modelContent[index], playerModel: $playerModel, showVideo: $showVideo)
                                    .frame(width: geo.size.width, height:geo.size.height - 48)
                                    .id(index)
                                    .padding(0)
                            }
                        }).scrollTargetLayout()
                            .onChange(of: currentIndex) { oldValue, newValue in
                                if abs(newValue - oldValue) > 1 {
                                    scrollViewProxy.scrollTo(newValue, anchor: .center)
                                    guard currentIndex < modelContent.count else {
                                        content = modelContent[modelContent.count - 1]
                                        return
                                    }
                                    content = modelContent[currentIndex]
                                } else {
                                    withAnimation {
                                        scrollViewProxy.scrollTo(newValue, anchor: .center)
                                        guard currentIndex < modelContent.count else {
                                            content = modelContent[modelContent.count - 1]
                                            return
                                        }
                                        content = modelContent[currentIndex]
                                    }
                                }
                            }
                            .onChange(of: content) { oldValue, newValue in
                                withAnimation {
                                    if let content = content {
                                        let newIndex = modelContent.firstIndex(of: content) ?? 0
                                        guard newIndex < modelContent.count else {
                                            return
                                        }
                                        if currentIndex != newIndex {
                                            scrollViewProxy.scrollTo(currentIndex, anchor: .center)
                                            self.content = modelContent[currentIndex]
                                        }
                                    }
                                }
                            }.onChange(of:showVideo) { oldValue, newValue in
                                if newValue {
                                    Task { @MainActor in
playerModel.loadVideo(URL(string:content!.videoURLString!)!,presentation: .inline)
                                    }
                                }
                            }
                            .onAppear {
                                scrollViewProxy.scrollTo(currentIndex, anchor: .center)
                                guard currentIndex < modelContent.count else {
                                    content = modelContent[modelContent.count - 1]
                                    return
                                }
                                self.content = modelContent[currentIndex]
                            }
                        
                    }
                    .scrollDisabled(true)
                    .scrollTargetBehavior(.paging)
                    
                })
            }
            .overlay {
                    VStack{
                        HStack {
                            if currentIndex > 0 {
                                Button {
                                    scroll(to: currentIndex - 1)
                                } label: {
                                    Label("previous", systemImage: "chevron.left")
                                }
                                .labelStyle(.iconOnly)
                                .padding(24)
                            } else {
                                Button {
                                    content = nil
                                    showItemView = false
                                } label: {
                                    Label("Gallery", systemImage: "chevron.left")
                                }
                                .labelStyle(.titleAndIcon)
                                .padding(24)
                            }
                            Spacer()
                            
                            if currentIndex < modelContent.count - 1{
                                Button {
                                    scroll(to: currentIndex + 1)
                                } label: {
                                    Label("next", systemImage: "chevron.right")
                                }
                                .labelStyle(.iconOnly)
                                .padding(24)
                            } else {
                                Button {
                                    scroll(to: 0)
                                } label: {
                                    Label("next", systemImage: "chevron.right")
                                }
                                .labelStyle(.iconOnly)
                                .padding(24)
                            }
                        }
                        Spacer()
                    }
                }
        })
        .popover(isPresented: $showVideo) {
            PlayerViewController(model: $playerModel)
                .interactiveDismissDisabled(!playerModel.isPlaybackComplete)
        }
    }
    
    private func scroll(to index: Int) {
        currentIndex = index.clamped(to: 0..<modelContent.count) // Adjust clamping range
    }
}

#Preview {
    DetailItemView(appState: .constant(TulaAppModel()), modelContent: .constant(TulaApp.defaultContent), content:.constant( TulaApp.defaultContent.first!), playerModel: .constant(PlayerModel()), currentIndex: .constant(0), showItemView: .constant(true))
}

extension Comparable {
    func clamped(to range: Range<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
