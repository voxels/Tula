//
//  TulaAppModel.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/9/24.
//

import Foundation
import ARKit
import RealityKit
import AVFoundation

@Observable
public class TulaAppModel {
    public var showImmersiveSpace:Bool = false
    public var immersiveSpaceIsShown:Bool = false
    public var hasPlaceableObjects:Bool{
        placeableObjectsByFileName.values.count > 0
    }
    var immersiveSpaceOpened: Bool { placementManager != nil }
    private(set) weak var placementManager: ARSessionManager? = nil

    private(set) var placeableObjectsByFileName: [String: PlaceableObject] = [:]
    private(set) var modelDescriptors: [ModelDescriptor] = []
    var selectedFileName: String?
    
    public var displayLinkTimestamp:Double = 0
    public var lastFrameDisplayLinkTimestamp:Double = 0
    private var displayLink:CADisplayLink!

    public init() {
        createDisplayLink()
    }
    
    func immersiveSpaceOpened(with manager: ARSessionManager) {
        placementManager = manager
    }

    func didLeaveImmersiveSpace() {
        // Remember which placed object is attached to which persistent world anchor when leaving the immersive space.
        if let placementManager {
            placementManager.saveWorldAnchorsObjectsMapToDisk()
            
            // Stop the providers. The providers that just ran in the
            // immersive space are paused now, but the session doesn’t need them anymore.
            // When the user reenters the immersive space, the app runs a new set of providers.
            //arkitSession.stop()
        }
        placementManager = nil
    }

    func setPlaceableObjects(_ objects: [PlaceableObject]) {
        placeableObjectsByFileName = objects.reduce(into: [:]) { map, placeableObject in
            map[placeableObject.descriptor.fileName] = placeableObject
        }

        // Sort descriptors alphabetically.
        modelDescriptors = objects.map { $0.descriptor }.sorted { lhs, rhs in
            lhs.displayName < rhs.displayName
        }
   }
    
    // MARK: - ARKit state

    var arkitSession = ARKitSession()
    var providersStoppedWithError = false
    var worldSensingAuthorizationStatus = ARKitSession.AuthorizationStatus.notDetermined
    
    var allRequiredAuthorizationsAreGranted: Bool {
        worldSensingAuthorizationStatus == .allowed
    }

    var allRequiredProvidersAreSupported: Bool {
        WorldTrackingProvider.isSupported && PlaneDetectionProvider.isSupported
    }

    var canEnterImmersiveSpace: Bool {
        allRequiredAuthorizationsAreGranted && allRequiredProvidersAreSupported
    }

    func requestWorldSensingAuthorization() async {
        let authorizationResult = await arkitSession.requestAuthorization(for: [.worldSensing])
        worldSensingAuthorizationStatus = authorizationResult[.worldSensing]!
    }
    
    func queryWorldSensingAuthorization() async {
        let authorizationResult = await arkitSession.queryAuthorization(for: [.worldSensing])
        worldSensingAuthorizationStatus = authorizationResult[.worldSensing]!
    }

    func monitorSessionEvents() async {
        for await event in arkitSession.events {
            switch event {
            case .dataProviderStateChanged(_, let newState, let error):
                switch newState {
                case .initialized:
                    break
                case .running:
                    break
                case .paused:
                    break
                case .stopped:
                    if let error {
                        print("An error occurred: \(error)")
                        providersStoppedWithError = true
                    }
                @unknown default:
                    break
                }
            case .authorizationChanged(let type, let status):
                print("Authorization type \(type) changed to \(status)")
                if type == .worldSensing {
                    worldSensingAuthorizationStatus = status
                }
            default:
                print("An unknown event occured \(event)")
            }
        }
    }
}

extension TulaAppModel {
    private func createDisplayLink() {
        displayLink = CADisplayLink(target: self, selector:#selector(onFrame(link:)))
        displayLink.add(to: .main, forMode: .default)
    }
}


extension TulaAppModel {
    
    @objc func onFrame(link:CADisplayLink) {
        displayLinkTimestamp = link.timestamp
    }
}
