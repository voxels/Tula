//
//  PlayerViewController.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/22/24.
//

import AVKit
import SwiftUI

// This view is a SwiftUI wrapper over `AVPlayerViewController`.
struct PlayerViewController: UIViewControllerRepresentable {
    
    @Binding public var model:PlayerModel

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = model.makePlayerViewController()
        controller.videoGravity = .resizeAspect
        controller.modalPresentationStyle = .automatic
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}

