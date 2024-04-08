//
//  ContentView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 1/26/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import PassKit

public struct ContentView: View {
    @Binding public var appState: TulaAppModel
    @Binding public var modelLoader: ModelLoader
    @Binding public var shopifyModel:ShopifyModel
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var playerModel:PlayerModel
    @Binding public var selectedModel:ModelViewContent?
    @Binding public var placementModel:ModelViewContent?
    @State private var showARSpace = false
    @State private var showApplePay = false

    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    public var body: some View {
        DetailView(appState: $appState, modelLoader: $modelLoader, shopifyModel: $shopifyModel, modelContent: $modelContent, content:$selectedModel, playerModel: $playerModel, placementModel: $placementModel)
    }
}
