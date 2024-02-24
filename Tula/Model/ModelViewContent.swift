//
//  ModelViewContent.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 1/30/24.
//

import SwiftUI

public struct ModelViewContent: Identifiable, Equatable {
    public let id = UUID()
    public var title:String
    public var flowerModelName:String
    public var floorPotModelName:String
    public var backgroundColor:Color
    public var image1URLString:String
    public var image2URLString:String
    public var image3URLString:String
    public var image4URLString:String?
    public var videoURLString:String
    public var smallPrice:Float?
    public var largePrice:Float?
    public var specimenPrice:Float?
    public var description:String
    let attachmentID:String = UUID().uuidString
}
