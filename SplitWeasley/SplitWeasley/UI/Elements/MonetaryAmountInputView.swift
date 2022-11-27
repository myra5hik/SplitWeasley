//
//  MonetaryAmountInputView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 23/11/22.
//

import SwiftUI

struct MonetaryAmountInputView: View {
    @StateObject var inputProxy: MonetaryAmountInputProxy
    @Binding var boundTo: MonetaryAmount

    init(monetaryAmount: Binding<MonetaryAmount>) {
        self._inputProxy = StateObject(
            wrappedValue: MonetaryAmountInputProxy(currency: monetaryAmount.wrappedValue.currency)
        )
        self._boundTo = monetaryAmount
    }

    var body: some View {
        TextField(text: $inputProxy.amountAsString) {
            makeTextLabel()
        }
        .keyboardType(.decimalPad)
        // Following modifiers bind proxy to the injected binding
        .onChange(of: boundTo) {
            inputProxy.amountAsDecimal = $0.amount
            inputProxy.currency = $0.currency
        }
        .onChange(of: inputProxy.amountAsDecimal) {
            boundTo = boundTo.with(amount: $0)
        }
        .onChange(of: inputProxy.currency) {
            boundTo = boundTo.with(currency: $0)
        }
    }

    private func makeTextLabel() -> some View {
        var placeholder = "0"
        let currency = inputProxy.currency
        if currency.roundingScale > 0 {
            placeholder += Locale.current.decimalSeparator ?? ""
            placeholder += Array(repeating: "0", count: currency.roundingScale)
        }
        placeholder += " \(currency.iso4217code)"
        return Text(placeholder)
    }
}

struct MonetaryAmountInput_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MonetaryAmountInputView(monetaryAmount: .constant(MonetaryAmount(currency: .eur)))
            MonetaryAmountInputView(monetaryAmount: .constant(MonetaryAmount(currency: .jpy)))
        }
        .font(.title)
        .padding()
    }
}
