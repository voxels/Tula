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
    public let modelContent:[ModelViewContent]
    @Binding public var selectedModel:ModelViewContent?
    @Binding public var placementModel:ModelViewContent?
    @State private var showARSpace = false
    @State private var showApplePay = false

    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    public init(appState: TulaAppModel, modelLoader: ModelLoader, modelContent:[ModelViewContent], selectedModel:Binding<ModelViewContent?>, placementModel:Binding<ModelViewContent?>) {
        
        self.appState = appState
        self.modelLoader = modelLoader
        self.modelContent = modelContent
        _selectedModel = selectedModel
        _placementModel = placementModel
    }
    
    public var body: some View {

        DetailView(appState: appState, modelContent:modelContent, content: $selectedModel, placementModel: $placementModel)
    }
}
