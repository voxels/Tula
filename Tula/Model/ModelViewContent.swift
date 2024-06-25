//
//  ModelViewContent.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 1/30/24.
//

import SwiftUI

public typealias ModelViewContentImageData = (url:URL, width:Int, height:Int, altText:String?)
public struct ModelViewContentVariantData : Identifiable, Hashable {
    public let id:String
    public let title:String
    public let amount:Decimal
    public let currencyCode:String
    public let availableForSale:Bool
    public let quantityAvailable:Int
}

public class ModelViewContent: Identifiable, Equatable, Hashable {
    public static func == (lhs: ModelViewContent, rhs: ModelViewContent) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id = UUID()
    public let productId:String
    public var title:String
    public var description:String
    public var featuredImage:ModelViewContentImageData?
    public var usdzModelName:String
    public var usdzFullSizeModelName:String
    public var imagesData:[ModelViewContentImageData]
    public var localImages:[String]
    public var videoURLString:String?
    public var variantPrices:[ModelViewContentVariantData]
    let attachmentID:String = UUID().uuidString
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }
    
    public init(productId: String, title: String, description: String, featuredImage: ModelViewContentImageData? = nil, usdzModelName: String, usdzFullSizeModelName: String, imagesData: [ModelViewContentImageData], localImages: [String], videoURLString: String? = nil, variantPrices: [ModelViewContentVariantData]) {
        self.productId = productId
        self.title = title
        self.description = description
        self.featuredImage = featuredImage
        self.usdzModelName = usdzModelName
        self.usdzFullSizeModelName = usdzFullSizeModelName
        self.imagesData = imagesData
        self.localImages = localImages
        self.videoURLString = videoURLString
        self.variantPrices = variantPrices
    }
}
