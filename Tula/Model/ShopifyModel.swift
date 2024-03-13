//
//  ShopifyModel.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 3/10/24.
//

import Foundation
import Buy
    
public struct ShopifyCollectionResponse: Equatable, Identifiable, Hashable {
    public static func == (lhs: ShopifyCollectionResponse, rhs: ShopifyCollectionResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id:UUID = UUID()
    public let collection:Storefront.Collection
    public let productResponses:[ShopifyProductResponse]
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


public struct ShopifyProductResponse : Equatable, Identifiable {
    public static func == (lhs: ShopifyProductResponse, rhs: ShopifyProductResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id:UUID = UUID()
    public let title:String
    public let description:String
    public let availableForSale:Bool
    public let product:Storefront.Product
    public let featuredImage:Storefront.Image?
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

    public var collectionResponses = [ShopifyCollectionResponse]()
    
    
    public func modelViewContent(for collectionID:String) -> [ModelViewContent] {
        var newContent = [ModelViewContent]()
        guard let response = collectionResponses.first(where: { response in
            response.collection.id.rawValue == collectionID
        }) else {
            return newContent
        }
        
        for productResponse in response.productResponses {
            var imagesData = [String]()
            var variantsData = [ModelViewContentVariantData]()
            for image in productResponse.images {
                let newImageData = image.url.absoluteString
                imagesData.append(newImageData)
            }
            
            for variant in productResponse.variants {
                let newVariantData =  (id:variant.id.rawValue, title:variant.title, amount:variant.price.amount, currencyCode: variant.price.currencyCode.rawValue, availableForSale:variant.availableForSale, quantityAvailable:Int(variant.quantityAvailable ?? 0))
                variantsData.append(newVariantData)
            }
            
            var featuredImageData:String?
            if let featuredImage = productResponse.featuredImage {
                featuredImageData = featuredImage.url.absoluteString
            }
            
            let modelContent = ModelViewContent(title: productResponse.title, description: productResponse.description, featuredImage:featuredImageData, usdzModelName: usdzModelName(for: productResponse.product.id.rawValue), usdzFullSizeModelName: usdzModelName(for: productResponse.product.id.rawValue), imagesData: imagesData, variantPrices: variantsData)
            print(productResponse.product.id.rawValue)
            print(productResponse.title)
            newContent.append(modelContent)
        }
        
        return newContent
    }
    
    private func usdzModelName(for productID:String)->String {
        switch productID {
        default:
            return ""
        }
    }
    
    public func connect() async throws {
        shopifyAPIKey = try await cache.apiKey(for: .shopifyStorefront)
    }
    
    public func fetchCollectionResponses(responsesCompletion: @escaping (([ShopifyCollectionResponse]?)->())) {
        let query = Storefront.buildQuery { $0
            .collections(first:10) { $0
                .nodes { $0
                    .id()
                    .title()
                    .products(first: 100) { $0
                        .nodes { $0
                            .id()
                            .title()
                            .productType()
                            .description()
                            .availableForSale()
                            .featuredImage { image in
                                image.id()
                                image.url()
                                image.width()
                                image.height()
                                image.altText()
                            }
                            .images(first: 10) { $0
                                .nodes { $0
                                    .id()
                                    .url()
                                    .width()
                                    .height()
                                    .altText()
                                }
                            }
                            .priceRange { priceQuery in
                                priceQuery.minVariantPrice { moneyQuery in
                                    moneyQuery.amount()
                                    moneyQuery.currencyCode()
                                }
                                priceQuery.maxVariantPrice { moneyQuery in
                                    moneyQuery.amount()
                                    moneyQuery.currencyCode()
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
                }
            }
        }
        
        let task = client.queryGraphWith(query) { response, error in
            if let error = error {
                print(error)
                responsesCompletion(nil)
                return
            }
            if let collections = response?.collections.nodes {
                var newCollectionResponses = [ShopifyCollectionResponse]()
                collections.forEach { collection in
                    var productResponses = [ShopifyProductResponse]()
                    let products = collection.products.nodes
                    for product in products {
                        let response = ShopifyProductResponse(title: product.title, description: product.description, availableForSale: product.availableForSale, product: product, featuredImage: product.featuredImage, images: product.images.nodes, variants: product.variants.nodes)
                        productResponses.append(response)
                    }
                    let collectionResponse = ShopifyCollectionResponse(collection: collection, productResponses: productResponses)
                    newCollectionResponses.append(collectionResponse)
                }
                
                responsesCompletion(newCollectionResponses)
                
            }
            else {
                responsesCompletion(nil)
            }
        }
        task.resume()
    }
    
    public func fetchProductDetails(for id: GraphQL.ID, productDetailsCompletion: @escaping ((ShopifyProductResponse?)->())) {
        let query = Storefront.buildQuery { $0
            .product(id: id) { $0
                .id()
                .title()
                .productType()
                .description()
                .availableForSale()
                .featuredImage { image in
                    image.id()
                    image.url()
                    image.width()
                    image.height()
                    image.altText()
                }
                .images(first: 10) { $0
                    .nodes { $0
                        .id()
                        .url()
                        .width()
                        .height()
                        .altText()
                    }
                }
                .priceRange { priceQuery in
                    priceQuery.minVariantPrice { moneyQuery in
                        moneyQuery.amount()
                        moneyQuery.currencyCode()
                    }
                    priceQuery.maxVariantPrice { moneyQuery in
                        moneyQuery.amount()
                        moneyQuery.currencyCode()
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
            if let error = error {
                print(error)
                productDetailsCompletion(nil)
                return
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
            let availableForSale = product.availableForSale
            let featuredImage = product.featuredImage
            let productResponse = ShopifyProductResponse(title: title, description: description, availableForSale: availableForSale, product: product, featuredImage: featuredImage, images: images, variants: variants)
            productDetailsCompletion(productResponse)

        }

        task.resume()
    }
}
