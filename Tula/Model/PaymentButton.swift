//
//  PaymentButton.swift
//  Tula
//
//  Created by Michael A Edgcumbe on 2/22/24.
//

import SwiftUI
import UIKit
import PassKit
struct PaymentButton: View {
    var body: some View {
        Button(action: {

        }, label: {
            
            Label("Checkout", systemImage: "cart")
        } )
        .buttonStyle(.borderedProminent)
    }
}
struct PaymentButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return PaymentButtonHelper()
    }
}
struct PaymentButtonHelper: View {
    var body: some View {
        PaymentButtonRepresentable()
            .frame(minWidth: 100, maxWidth: 400)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .padding(8)        
    }
}
extension PaymentButtonHelper {
    struct PaymentButtonRepresentable: UIViewRepresentable {
     
        var button: PKPaymentButton {
            let button = PKPaymentButton(paymentButtonType: .checkout, paymentButtonStyle: .white) /*customize here*/
            button.cornerRadius = 22.0 /* also customize here */
            return button
        }
     
        func makeUIView(context: Context) -> PKPaymentButton {
            return button
        }
        func updateUIView(_ uiView: PKPaymentButton, context: Context) { }
    }
}
