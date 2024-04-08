//
//  ModelViewContent.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 1/30/24.
//

import SwiftUI

public typealias ModelViewContentImageData = (url:URL, width:Int, height:Int, altText:String?)
public typealias ModelViewContentVariantData = (id:String, title:String, amount:Decimal, currencyCode:String, availableForSale:Bool, quantityAvailable:Int)

public struct ModelViewContent: Identifiable, Equatable, Hashable {
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
}
