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
            .onChange(of: shopifyModel.productResponses) { oldValue, newValue in
                for response in newValue {
                    print(response.title)
                    print(response.description)
                }
            }
            .task {
                for response in shopifyModel.productResponses {
                    print(response.title)
                    print(response.description)
                }
                print(shopifyModel.productResponses.count)
            }
    }
}

#Preview {
    DetailCartView(shopifyModel: .constant(ShopifyModel()))
}
