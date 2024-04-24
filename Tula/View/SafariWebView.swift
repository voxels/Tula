//
//  SafariWebView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 4/23/24.
//

import SwiftUI
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

#Preview {
    SafariWebView(url: URL(string:"https://tula.house")!)
}
