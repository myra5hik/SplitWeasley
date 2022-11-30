//
//  NumericInputView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 23/11/22.
//

import SwiftUI

///
/// A text field designed for numeric inputs, bound to the provided source of truth.
/// It allows inputting:
/// a) solely numeric values;
/// b) up to the specified fractional digit limit (0, 0.00, 0.0000, etc.)
/// c) no more than one separator symbol within the number; and other corner cases.
///
struct NumericInputView<LFDIP: ILimitedFractionDigitInputProxy>: View {
    // State
    @ObservedObject private var inputProxy: LFDIP
    private let placeholder: String
    // Binding to the source of truth
    @Binding private var boundTo: Decimal

    init(
        _ binding: Binding<Decimal>,
        roundingScale: Int? = nil,
        placeholder: String,
        inputProxy: LFDIP.Type = LimitedFractionDigitInputProxy.self
    ) {
        self.inputProxy = inputProxy.init(
            roundingScale: roundingScale ?? 2,
            initialValue: binding.wrappedValue
        )
        self.placeholder = placeholder
        self._boundTo = binding
    }

    var body: some View {
        TextField(text: $inputProxy.amountAsString) { Text(placeholder) }
        .keyboardType(.decimalPad)
        // Following modifiers bind proxy to the injected binding
        .onChange(of: boundTo) {
            inputProxy.amountAsDecimal = $0
        }
        .onChange(of: inputProxy.amountAsDecimal) {
            boundTo = $0
        }
    }
}

struct MonetaryAmountInput_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NumericInputView(.constant(0), roundingScale: 0, placeholder: "0")
            NumericInputView(.constant(0), roundingScale: 2, placeholder: "0.00")
            NumericInputView(.constant(0), roundingScale: 6, placeholder: "0.0000")
        }
        .font(.title)
        .padding()
    }
}
