//
//  DetailCartView.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/15/24.
//

import SwiftUI

struct DetailCartView: View {
    
    @Binding public var shopifyModel:ShopifyModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    DetailCartView(shopifyModel: .constant(ShopifyModel()))
}
