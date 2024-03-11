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
    public let appState: TulaAppModel
    public let modelLoader: ModelLoader
    @Binding public var shopifyModel:ShopifyModel
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var selectedModel:ModelViewContent?
    @Binding public var placementModel:ModelViewContent?
    @State private var showARSpace = false
    @State private var showApplePay = false

    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    public init(appState: TulaAppModel, modelLoader: ModelLoader, shopifyModel:Binding<ShopifyModel>, modelContent:Binding<[ModelViewContent]>, selectedModel:Binding<ModelViewContent?>, placementModel:Binding<ModelViewContent?>) {
        
        self.appState = appState
        self.modelLoader = modelLoader
        _shopifyModel = shopifyModel
        _modelContent = modelContent
        _selectedModel = selectedModel
        _placementModel = placementModel    
    }
    
    public var body: some View {

        DetailView(appState: appState, shopifyModel: $shopifyModel, modelContent:$modelContent, content: $selectedModel, placementModel: $placementModel)
    }
}
