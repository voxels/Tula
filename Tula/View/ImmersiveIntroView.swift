//
//  ImmersveIntroView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/15/24.
//

import SwiftUI

struct ImmersiveIntroView: View {
    
    let appState: TulaAppModel
    @Binding public var content:ModelViewContent?
    @Binding public var placementModel:ModelViewContent?
    var body: some View {
        if appState.hasPlaceableObjects {
            let title = appState.immersiveSpaceIsShown ? "Leave Immersive Space" : "Open Immersive Space"
            Button(title, systemImage: "visionpro") {
                placementModel = nil
                appState.showImmersiveSpace.toggle()
            }
        } else {
            ProgressView("Loading Models")
        }

    }
}

#Preview {
    ImmersiveIntroView(appState: TulaAppModel(), content: .constant(TulaApp.defaultContent.first!), placementModel: .constant(nil))
}
