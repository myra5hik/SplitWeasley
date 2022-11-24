//
//  MonetaryAmountInputView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 23/11/22.
//

import SwiftUI

struct MonetaryAmountInputView: View {
    @StateObject private var inputProxy: MonetaryAmountInputProxy

    init(inputProxy: MonetaryAmountInputProxy) {
        self._inputProxy = StateObject(wrappedValue: inputProxy)
    }

    var body: some View {
        TextField(text: $inputProxy.amountAsString) {
            Text("0.0 \(inputProxy.currency.iso4217code)")
        }
        .keyboardType(.decimalPad)
    }
}

struct MonetaryAmountInput_Previews: PreviewProvider {
    static var previews: some View {
        let twoFractionalDigitProxy = MonetaryAmountInputProxy(MonetaryAmount(currency: .eur))
        let zeroFractionalDigitProxy = MonetaryAmountInputProxy(MonetaryAmount(currency: .jpy))

        VStack {
            MonetaryAmountInputView(inputProxy: twoFractionalDigitProxy)
            MonetaryAmountInputView(inputProxy: zeroFractionalDigitProxy)
        }
        .font(.title)
        .padding()
    }
}
