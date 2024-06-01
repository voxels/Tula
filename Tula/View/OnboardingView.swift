//
//  OnboardingView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 3/9/24.
//

import SwiftUI

struct OnboardingView: View {
    @Binding public var showOnboarding:Bool
    @Binding public var modelContent:[ModelViewContent]
    @Binding public var isReady:Bool
    var body: some View {
        if isReady {
            Button {
                showOnboarding = false
            } label: {
                Label("Welcome", systemImage: "leaf")
                    .labelStyle(.titleOnly)
            }.disabled(!isReady)
        } else {
            ProgressView()
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true), modelContent:.constant([]), isReady: .constant(true))
}
