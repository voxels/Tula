//
//  TulaApp.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 1/26/24.
//

import SwiftUI

@main
@MainActor
struct TulaApp: App {
    
    @State private var appState = TulaAppModel()
    @State private var modelLoader = ModelLoader()
    @State private var placementManager = ARSessionManager()
    @State private var selectedModel:ModelViewContent?
    @State private var placementModel:ModelViewContent?
    @State private var playerModel = PlayerModel()
    @State private var shopifyModel = ShopifyModel()
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.scenePhase) private var scenePhase
    
    static let defaultContent:[ModelViewContent] =
    [
        ModelViewContent(title: "Euphorbia abdelkuri Silver", description: "The captivating Philodendron Gloriosum – a stunning plant that will mesmerize you with its velvety heart-shaped leaves and striking white veins. In its native habitat of Central and South America, the Philodendron gloriosum finds sanctuary amidst the dappled sunlight, its velvety leaves unfurling beneath the towering trees. \n\nPhilodendron Gloriosum thrives in bright, indirect light. Avoid harsh, direct sunlight as it can scorch the leaves. A spot near an east-facing window or filtered light from a sheer curtain will be perfect. \n\nKeep the soil consistently moist but not waterlogged. Allow the top inch of soil to dry out before watering again. Overwatering can lead to root rot, so it's best to err on the side of slightly underwatering. Being native to tropical regions, the Philodendron Gloriosum loves humidity. Boost humidity by misting the leaves regularly or placing a humidity tray nearby.", usdzModelName: "cactus_scene", usdzFullSizeModelName: "cactus_volume_scene", imagesData:["Tula-House-Philodendron-gloriosum-1", "Tula-House-Philodendron-gloriosum-4", "Tula-House-Philodendron-gloriosum-2", "Tula-House-Philodendron-gloriosum-3"], variantPrices: [(id:"small", title:"Small", amount:10, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"large", title:"Large", amount:20, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"specimen", title:"Specimen", amount:38, currencyCode:"USD", availableForSale:true, quantityAvailable:100)], videoURLString: "https://customer-02f18dl7ud0edmeq.cloudflarestream.com/8e7bc7d8ea351ba87fc74cc672d437ca/manifest/video.m3u8"),
        ModelViewContent(title: "Philodendron gloriosum", description: "The Euphorbia abdelkuri is a rare succulent plant with grey coloration that shines iridescent in the sun. It forms densely branched candelabra-like clumps, usually not more than 3 feet in height. It is one of the most coveted Euphorbia species. \n\nEuphorbia do best with a few hours of direct sun in the morning or late afternoon. Filtered light during the sun’s peak hours will keep this plant from bleaching. Avoid intense afternoon sun. Water thoroughly during the hot summer months. Let the soil somewhat dry out between waterings. During the winter months, water only when the soil becomes completely dry. Cold temperatures, low light and wet soil can lead to root or stem rot. \n\nEuphorbia can be propagated from stem cuttings. Take great care when cutting these plants as they contain a sap that can be highly irritant if contacted with skin. Allow cuttings to callous for several days before dusting with rooting hormone and placing in soil. Fertilize to stimulate growth and healthy roots.", usdzModelName: "green_scene", usdzFullSizeModelName: "green_volume_scene", imagesData:["Tula-House-Euphorbia-abdelkuri-Silver-3","Tula-House-Euphorbia-abdelkuri-Silver-close","Tula-House-Euphorbia-abdelkuri-Silver-2", "Tula-House-Euphorbia-abdelkuri-Silver-4" ], variantPrices: [(id:"small", title:"Small", amount:10, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"large", title:"Large", amount:20, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"specimen", title:"Specimen", amount:225, currencyCode:"USD", availableForSale:true, quantityAvailable:100)], videoURLString: "https://customer-02f18dl7ud0edmeq.cloudflarestream.com/39995255f361f407886b004a0b50b1ba/manifest/video.m3u8"),
        ModelViewContent(title: "Monstera pinnatipartita Siam", description: "The Monstera pinnatipartita Siam, is a rare variety of Monstera, loved for its shiny, textured foliage. Native to the tropics of South America, this plant thrives when it latches its aerial roots and climbs vertically. \n\nThis tropical grows well in low-light, bright-indirect light, and dappled sunlight. Shield it from direct sunlight, which can scorch its delicate leaves, and watch it thrive in a space where the light is filtered through sheer curtains or placed a few feet away from a window. \n\nMonsteras like the soil to dry somewhat in between waterings. Once the top half feels dry to the touch, feel free to water again. They can dry out completely, but don’t leave it for too long without water.", usdzModelName: "alocasia_scene", usdzFullSizeModelName: "alocasia_volume_scene", imagesData:["Tula-House-Monstera-pinnatipartita-siam-1","Tula-House-Monstera-pinnatipartita-siam-2","Tula-House-Monstera-pinnatipartita-siam-3","Tula-House-Monstera-pinnatipartita-siam-4"], variantPrices: [(id:"small", title:"Small", amount:10, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"large", title:"Large", amount:20, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"specimen", title:"Specimen", amount:48, currencyCode:"USD", availableForSale:true, quantityAvailable:100)], videoURLString: "https://customer-02f18dl7ud0edmeq.cloudflarestream.com/46a841ffd7d4d61b1574ea98f7dd8be9/manifest/video.m3u8"),
        ModelViewContent(title: "Melocactus matanzanus", description: "A native to Cuba, the Melocactus matanzanus is an etraordinary cactus. When it reaches a certain age of maturity, the Melocactus grows a cephalium from its center. This structure is where the flower buds will form and bloom. The size of the cephalium can signify how old the plant is. \n\nThe Melocactus prefer at least 4 to 6 hours of sun daily. Indoors a south facing window is ideal. Water only when the soil has dried out completely. Always err on the side of under-watering. They are built to withstand drought. \n\nFertilize starting in spring through summer to promote healthy growth and root systems.", usdzModelName: "succulent_scene", usdzFullSizeModelName: "succulent_volume_scene", imagesData:["Tula-House-Melocactus-matanzanus-large-1","Tula-House-Melocactus-matanzanus-closeup-1","Tula-House-Melocactus-matanzanus-large-2","Tula-House-Melocactus-matanzanus-large-hand"], variantPrices: [(id:"small", title:"Small", amount:28, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"large", title:"Large", amount:65, currencyCode:"USD", availableForSale:true, quantityAvailable:100)], videoURLString: "https://customer-02f18dl7ud0edmeq.cloudflarestream.com/dc47cdbca09ef9a333e77cc4ac4c226b/manifest/video.m3u8"),
        ModelViewContent(title: "Myrtillocactus geometrizans fukurokuryuzinboku", description: "Myrtillocactus geometrizans Fukurokuryuzinboku aka 'The Boob Cactus' is a monstrose cultivar of the more commonly seen Myrtillocactus geometrizans. The Fukurokuryuzinboku has unusual shaped ribs along with areoles that resemble nipples making this cactus appear like it has little breasts, hence the popular nickname, ‘The Boob or Boobie Cactus’. The 'Boobie Cactus' is a nursery produced cultivar which is a collectable amongst enthusiasts. \n\nThe Boobie cactus requires direct sun to grow evenly but be careful of very hot windowsills during summer months as the magnification from the glass can burn the spineless surface.Water only when the soil has dried out entirely. Always err on the side of under-watering. Fertilize starting in spring through summer to promote healthy growth and strong root systems.", usdzModelName: "spike_scene", usdzFullSizeModelName: "spike_volume_scene", imagesData:["Tula-House-Fukurokuryuzinboku-small-1_900x","Tula-House-Myrtillocactus-geometrizans-Fukurokuryuzinboku-1","Tula-House-Myrtillocactus-geometrizans-Fukurokuryuzinboku-closeup","Tula-House-Myrtillocactus-geometrizans-Fukurokuryuzinboku-hand" ], variantPrices: [(id:"small", title:"Small", amount:36, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"large", title:"Large", amount:48, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"specimen", title:"Specimen", amount:75, currencyCode:"USD", availableForSale:true, quantityAvailable:100)], videoURLString: "https://customer-02f18dl7ud0edmeq.cloudflarestream.com/67ce7e991a05eb413ecaa3aaf92ed09f/manifest/video.m3u8"),
        ModelViewContent(title: "Myrtillocactus geometrizans crested", description: "The Myrtillocactus geometrizans crested is a highly sought after and rare form of the Myrtillocactus geometrizans. The crested formation occurs naturally in a clumping manner that can take years to build in height. The cactus is more or less spineless, its blue coloration will become more saturated with the proper sunlight. \n\nThe Myrtillocactus requires direct sun to grow evenly but be careful of very hot windowsills during summer months as the magnification from the glass can burn the spineless surface. \n\nAllow the soil to dry completely between watering and water thoroughly in the grow season. Fertilize Myrtillocactus geometrizans starting in spring through summer to promote healthy growth and strong root systems.", usdzModelName: "begonia_scene", usdzFullSizeModelName: "begonia_volume_scene", imagesData:["Tula-House-Myrtillocactus-geometrizans-Crested-small-1","Tula-House-Myrtillocactus-geometrizans-Crested-medium-1","Tula-House-Myrtillocactus-geometrizans-Crested-closeup-1","Tula-House-Myrtillocactus-geometrizans-Crested-medium-hand" ], variantPrices: [(id:"small", title:"Small", amount:22, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"large", title:"Large", amount:45, currencyCode:"USD", availableForSale:true, quantityAvailable:100)], videoURLString: "https://customer-02f18dl7ud0edmeq.cloudflarestream.com/91c2d1e1f039ae639b56b90a611213bb/manifest/video.m3u8"),
        ModelViewContent(title: "Echinocereus rigidissimus var Rubrispinus", description: "Echinocereus rigidissimus var. rubrispinus is commonly called the rainbow hedgehog cactus and best known for its beautiful pink coloration. This petite plant typically grows to reach 30 cm tall by 11 cm wide. Aptly named, it bears new spines that are magenta colored and fade to yellow or light pink with maturity. Echinocereus rigidissimus grows as a stocky, solitary stem, rarely producing offsets. Endemic to parts of northwest Mexico and southwest United States, it can be found growing on rocky slopes at high elevation. \n\nEchinocereus rigidissimus are desert cacti that require full sun. The more sun this cactus receives, the more brilliant the spine coloration will become. Echinocereus rigidissimus plants are extremely drought tolerant. Water them thoroughly, fully saturating the soil. Always allow the soil to dry out completely in between waterings. \n\nEchinocereus rigidissimus var. rubrispinus flower in the spring, from late April to early June. Flowers buds are borne in clusters from the top of the cacti. Blossoms are bright pink in color. Fertilize during the growing season to stimulate growth and blooms.", usdzModelName: "house_scene", usdzFullSizeModelName: "house_volume_scene", imagesData:["Tula-House-Echinocereus-rigidissimus-var-Rubrispinus-1","Tula-House-Echinocereus-rigidissimus-var-Rubrispinus-2","Tula-House-Echinocereus-rigidissimus-var-Rubrispinus-closeup","Tula-House-Echinocereus-rigidissimus-var-Rubrispinus-hand-2"], variantPrices: [(id:"small", title:"Small", amount:18, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"specimen", title:"Specimen", amount:45, currencyCode:"USD", availableForSale:true, quantityAvailable:100)], videoURLString: "https://customer-02f18dl7ud0edmeq.cloudflarestream.com/2d105393ea4ac6a423834d4eb748a843/manifest/video.m3u8"),
        ModelViewContent(title: "Cereus forbesii spiralis", description: "The Cereus Forbesii 'Spiralis' is a rare cultivar of the Cereus forbesii prized for it's spiral growth habit. When grown from seed, the Spiralis won't start twisting until it reaches a height of 3-4 tall. \n\nThe Spiralis should be grown in a mix of direct and indirect sun and dry conditions. During the grow season, it should be watered thoroughly, when the soil is dry. During cold, winter months, it should be left to dry between waterings and watered sparingly. \n\nThe spiralis will bloom big, beautiful white blossoms between June and August. Ensure the light requirements are met and increase watering and fertilization. The blossoms only open at night and span 2-4 wide. Spiralis can be fed with a cactus fertilizer once per month, spring through fall.", usdzModelName: "cereus_scene", usdzFullSizeModelName: "cereus_volume_scene", imagesData:["Tula-House-Cereus-forbesii-spiralis-small-1","Tula-House-Cereus-forbesii-spiralis-1","Tula-House-Cereus-forbesii-spiralis-closeup","Tula-House-Cereus-forbesii-spiralis-hand"], variantPrices: [(id:"small", title:"Small", amount:36, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"large", title:"Large", amount:68, currencyCode:"USD", availableForSale:true, quantityAvailable:100), (id:"specimen", title:"Specimen", amount:125, currencyCode:"USD", availableForSale:true, quantityAvailable:100)], videoURLString: "https://customer-02f18dl7ud0edmeq.cloudflarestream.com/37d8b682e5e6f0ac576f0610c87da1f2/manifest/video.m3u8")
    ]
    
    @State private var modelContent:[ModelViewContent] = []
    @State private var showOnboarding = true
    
    var body: some Scene {
        WindowGroup("Tula House", id: "ContentView", content: {
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding, modelContent: $modelContent)
                    .task {
                        modelContent = TulaApp.defaultContent
                    }
                    .task { @MainActor in
                        do {
                            try await shopifyModel.connect()
                            print("fetching products")
                            shopifyModel.fetchCollectionResponses(responsesCompletion: { collections in
                                guard let collections = collections else {
                                    print("found no shopify collections")
                                    return
                                }
                                
                                print("Found products \(collections.count)")
                                for collection in collections {
                                    print(collection.collection.id)
                                    print(collection.collection.title)
                                }
                                shopifyModel.collectionResponses = collections
                                if let firstCollection = shopifyModel.collectionResponses.first {
                                    modelContent = shopifyModel.modelViewContent(for: firstCollection.collection.id.rawValue)
                                }
                            })
                            
                        } catch {
                            print(error)
                        }
                    }
            } else {
                ContentView( appState: $appState, modelLoader: $modelLoader, shopifyModel: $shopifyModel, modelContent: $modelContent, selectedModel: $selectedModel, placementModel: $placementModel )
                    .onChange(of: modelContent, { oldValue, newValue in
                        Task {
                            await modelLoader.loadObjects(content: newValue)
                            appState.setPlaceableObjects(modelLoader.placeableObjects)
                        }
                    })
                    .onChange(of: selectedModel, { oldValue, newValue in
                        if newValue == nil {
                            placementModel = nil
                        }
                    })
                    .onChange(of: appState.showImmersiveSpace) { _, newValue in
                        Task {
                            if newValue && !appState.immersiveSpaceIsShown  && appState.canEnterImmersiveSpace {
                                
                                switch await openImmersiveSpace(id: "ImmersiveSpace") {
                                case .opened:
                                    if let placementModel = placementModel{
                                        appState.placementManager?.select(appState.placeableObjectsByFileName[placementModel.usdzModelName])
                                    }
                                    appState.immersiveSpaceIsShown = true
                                    
                                    
                                case .error, .userCancelled:
                                    fallthrough
                                @unknown default:
                                    appState.immersiveSpaceIsShown = false
                                    appState.showImmersiveSpace = false
                                }
                            } else if appState.immersiveSpaceIsShown {
                                appState.placementManager?.select(nil)
                                await dismissImmersiveSpace()
                                appState.immersiveSpaceIsShown = false
                            } else {
                                print("ARKit error")
                            }
                        }
                    }
                    .onChange(of: scenePhase, initial: true) {
                        print("HomeView scene phase: \(scenePhase)")
                        if scenePhase == .active {
                            Task {
                                // Check whether authorization has changed when the user brings the app to the foreground.
                                await appState.queryWorldSensingAuthorization()
                            }
                        } else {
                            // Leave the immersive space if this view is no longer active;
                            // the controls in this view pair up with the immersive space to drive the placement experience.
                            if appState.immersiveSpaceOpened {
                                Task {
                                    await dismissImmersiveSpace()
                                    appState.didLeaveImmersiveSpace()
                                }
                            }
                        }
                    }
                    .onChange(of: appState.providersStoppedWithError, { _, providersStoppedWithError in
                        // Immediately close the immersive space if there was an error.
                        if providersStoppedWithError {
                            if appState.immersiveSpaceOpened {
                                Task {
                                    await dismissImmersiveSpace()
                                    appState.didLeaveImmersiveSpace()
                                }
                            }
                            
                            appState.providersStoppedWithError = false
                        }
                    })
                    .task {
                        // Request authorization before the user attempts to open the immersive space;
                        // this gives the app the opportunity to respond gracefully if authorization isn’t granted.
                        if appState.allRequiredProvidersAreSupported {
                            await appState.requestWorldSensingAuthorization()
                        }
                    }
                    .task {
                        // Monitors changes in authorization. For example, the user may revoke authorization in Settings.
                        await appState.monitorSessionEvents()
                    }
            }
        }).windowResizability(.contentSize)
        
        WindowGroup("Video Player", id:"VideoPlayer", content: {
            if let videoURLString = selectedModel?.videoURLString {
                PlayerViewController(model: $playerModel)
                    .padding(32)
                    .onDisappear(perform: {
                        playerModel.stop()
                    })
                    .task { @MainActor in
                        do {
                            try await playerModel.loadVideo(URL(string:videoURLString)!,presentation: .fullWindow )
                        } catch {
                            print(error)
                        }
                    }.foregroundStyle(.clear)
            } else {
                ContentUnavailableView("Video not available", image: "gobackward")
            }
        })
        .defaultSize(CGSizeMake(640, 800))
        
        WindowGroup("Tula House", id: "VolumeSmallView", content: {
            if let model = selectedModel {
                VolumeView(appState: $appState, modelLoader: $modelLoader, shopifyModel: $shopifyModel, model: model, modelContent: $modelContent, placementModel: $placementModel)
            } else {
                ProgressView("No model selected")
            }
        })
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1.2, depth:1, in: .meters)

        WindowGroup("Tula House", id: "VolumeLargeView", content: {
            if let model = selectedModel {
                VolumeView(appState: $appState, modelLoader: $modelLoader,  shopifyModel: $shopifyModel, model: model, modelContent: $modelContent,  placementModel: $placementModel)
            } else {
                ProgressView("No model selected")
            }
        })
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1.2, depth: 1, in: .meters)

        
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            
            ImmersiveView(appState: $appState, modelLoader: $modelLoader, placementManager: $placementManager, selectedModel: $selectedModel, placementModel: $placementModel)

            }
        .onChange(of: scenePhase, initial: true) {
            if scenePhase != .active {
                // Leave the immersive space when the user dismisses the app.
                if appState.immersiveSpaceOpened {
                    Task {
                        await dismissImmersiveSpace()
                        appState.didLeaveImmersiveSpace()
                    }
                }
            }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
    }
}
