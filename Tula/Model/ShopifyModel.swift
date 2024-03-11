//
//  ShopifyModel.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 3/10/24.
//

import Foundation
import Buy

public struct ShopifyProductResponse : Equatable, Identifiable {
    public static func == (lhs: ShopifyProductResponse, rhs: ShopifyProductResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id:UUID = UUID()
    public let title:String
    public let description:String
    public let product:Storefront.Product
    public let images:[Storefront.Image]
    public let variants:[Storefront.ProductVariant]
}

@Observable open class ShopifyModel {
    
    private let cache = CloudCache()
    public var isAuthenticated:Bool {
        return !shopifyAPIKey.isEmpty
    }
    private var shopifyAPIKey:String = ""
    private var client:Graph.Client {
        get {
            return Graph.Client.init(shopDomain: CloudCache.shopifyWebAddressString, apiKey: shopifyAPIKey)
        }
    }
    
    public var productResponses = [ShopifyProductResponse]()
    
    public func connect() async throws {
        shopifyAPIKey = try await cache.apiKey(for: .shopifyStorefront)
    }
    
    public func fetchProducts(productCompletion: @escaping (([Storefront.Product]?)->())) {
        let query = Storefront.buildQuery { $0
            .collections(first:10) { $0
                .nodes { $0
                    .id()
                    .title()
                    .products(first: 50) { $0
                        .nodes { $0
                            .id()
                            .title()
                            .productType()
                            .description()
                        }
                    }
                }
            }
        }
        
        let task = client.queryGraphWith(query) { response, error in
            if let collections = response?.collections.nodes {
                var allProducts = [Storefront.Product]()
                collections.forEach { collection in
                    let products = collection.products.nodes
                    allProducts.append(contentsOf: products)
                }
                productCompletion(allProducts)
            }
        }
        task.resume()
    }
    
    public func fetchProductDetails(for id: GraphQL.ID, productDetailsCompletion: @escaping ((ShopifyProductResponse?)->())) {
        let query = Storefront.buildQuery { $0
            .product(id: id) { $0
                .title()
                .description()
                .images(first: 10) { $0
                    .nodes { $0
                        .url()
                    }
                }
                .variants(first: 50) { $0
                    .nodes { $0
                        .id()
                        .title()
                        .price { $0
                            .amount()
                            .currencyCode()
                        }
                        .availableForSale()
                        .quantityAvailable()
                    }
                }
            }
        }

        let task = client.queryGraphWith(query) { response, error in
            if let e = error {
                print(e)
            }
            
            guard let response = response else {
                productDetailsCompletion(nil)
                return
            }
            
            
            guard let product  = response.product else {
                productDetailsCompletion(nil)
                return
            }

            let title = product.title
            let description = product.description
            let images   = product.images.nodes
            let variants = product.variants.nodes
            let productResponse = ShopifyProductResponse(title: title, description: description, product: product, images: images, variants: variants)
            productDetailsCompletion(productResponse)

        }

        task.resume()
    }
}
