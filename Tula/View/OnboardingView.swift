//
//  OnboardingView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 3/9/24.
//

import SwiftUI

struct OnboardingView: View {
    @Binding public var showOnboarding:Bool
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
