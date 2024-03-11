//
//  DetailItemView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/15/24.
//

import SwiftUI

struct DetailItemView: View {
    let appState: TulaAppModel
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var content:ModelViewContent?
    @State private var currentIndex = 0
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
                                ItemView(appState: appState, content: $modelContent[index], showVideo: $showVideo)
                                    .frame(width: geo.size.width, height:geo.size.height - 48)
                                    .id(index)
                                    .padding(0)
                            }
                        }).scrollTargetLayout()
                            .onChange(of: currentIndex) { oldValue, newValue in
                                withAnimation {
                                    scrollViewProxy.scrollTo(newValue, anchor: .center)
                                    guard currentIndex < modelContent.count else {
                                        content = modelContent[modelContent.count - 1]
                                        return
                                    }
                                    content = modelContent[currentIndex]
                                }
                            }
                            .onAppear {
                                if let content = content {
                                    currentIndex = modelContent.firstIndex(of: content) ?? 0
                                }
                                
                                scrollViewProxy.scrollTo(currentIndex, anchor: .center)
                                content = modelContent[currentIndex]
                            }
                        
                    }
                    .scrollDisabled(true)
                    .scrollTargetBehavior(.paging)
                    
                })
            }
            .overlay {
                if showVideo {
                    EmptyView()
//                    VStack{
//                        HStack {
//                            Button {
//                                
//                                showVideo.toggle()
//                            } label: {
//                                Label("previous", systemImage: "chevron.left")
//                            }
//                            .labelStyle(.iconOnly)
//                            .padding(24)
//                            Spacer()
//                        }
//                        Spacer()
//                    }

                } else {
                    VStack{
                        HStack {                            
                            if currentIndex > 0{
                                Button {
                                    scroll(to: currentIndex - 1)
                                } label: {
                                    Label("previous", systemImage: "chevron.left")
                                }
                                .labelStyle(.iconOnly)
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
                            }
                        }
                        Spacer()
                    }
                }
            }
        })
    }
    
    private func scroll(to index: Int) {
        currentIndex = index.clamped(to: 0..<modelContent.count) // Adjust clamping range
    }
}

#Preview {
    DetailItemView(appState: TulaAppModel(), modelContent: .constant(TulaApp.defaultContent), content:.constant( TulaApp.defaultContent.first!))
}

extension Comparable {
    func clamped(to range: Range<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
