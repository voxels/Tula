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
    @State private var isReady:Bool = false
    var body: some View {
        Button {
            showOnboarding = false
        } label: {
            Label("Welcome", systemImage: "plant")
                .labelStyle(.titleOnly)
        }.disabled(!isReady)
            .task {
                if modelContent.count > 0 {
                    isReady = true
                }
            }
            .onChange(of: modelContent) { oldValue, newValue in
                if newValue.count > 0 {
                    isReady = true
                } else {
                    isReady = false
                }
            }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true), modelContent:.constant([]))
}
