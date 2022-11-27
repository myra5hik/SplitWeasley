//
//  MonetaryAmountInputView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 23/11/22.
//

import SwiftUI

///
/// A text field designed for monetary amount inputs, bound to the provided source of truth.
/// It allows inputting:
/// a) solely numeric values;
/// b) up to the currency's fractional digit limit (2 for most currencies, like in EUR, yet 0 in JPY);
/// c) no more than one separator symbol within the number; and other corner cases.
///
struct MonetaryAmountInputView<LFDIP: ILimitedFractionDigitInputProxy>: View {
    // State
    @StateObject private var inputProxy: LFDIP
    @State private var currencySymbol: String
    // Binding to the source of truth
    @Binding private var boundTo: MonetaryAmount

    init(
        monetaryAmount: Binding<MonetaryAmount>,
        inputProxy: LFDIP.Type = LimitedFractionDigitInputProxy.self
    ) {
        self._inputProxy = StateObject(
            wrappedValue: inputProxy.init(
                roundingScale: monetaryAmount.wrappedValue.currency.roundingScale
            )
        )
        self.currencySymbol = monetaryAmount.wrappedValue.currency.iso4217code
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
            inputProxy.roundingScale = $0.currency.roundingScale
            currencySymbol = boundTo.currency.iso4217code
        }
        .onChange(of: inputProxy.amountAsDecimal) {
            boundTo = boundTo.with(amount: $0)
        }
    }

    private func makeTextLabel() -> some View {
        var placeholder = "0"
        let roundingScale = inputProxy.roundingScale
        if roundingScale > 0 {
            placeholder += Locale.current.decimalSeparator ?? ""
            placeholder += Array(repeating: "0", count: min(roundingScale, 4))
        }
        placeholder += " \(currencySymbol)"
        return Text(placeholder)
    }
}

struct MonetaryAmountInput_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MonetaryAmountInputView(monetaryAmount: .constant(MonetaryAmount(currency: .eur)))
            MonetaryAmountInputView(monetaryAmount: .constant(MonetaryAmount(currency: .jpy)))
            MonetaryAmountInputView(monetaryAmount: .constant(MonetaryAmount(currency: .btc)))
        }
        .font(.title)
        .padding()
    }
}
