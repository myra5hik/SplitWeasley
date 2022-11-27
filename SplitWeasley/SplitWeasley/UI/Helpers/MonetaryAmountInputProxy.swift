//
//  MonetaryAmountInputProxy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 22/11/22.
//

import SwiftUI

protocol IMonetaryAmountInputProxy: ObservableObject {
    var amountAsString: String { get set }
    var amountAsDecimal: Decimal { get set }
    var currency: Currency { get set }
}

final class MonetaryAmountInputProxy: ObservableObject {
    private var monetaryAmount: MonetaryAmount {
        willSet { objectWillChange.send() }
    }
    // Inputs
    private let separator = "\(Locale.current.decimalSeparator ?? "")"
    // Logics
    private var shouldAddTrailingSeparator = false
    private var amountOfTrailingZeros = 0

    init(currency: Currency) {
        self.monetaryAmount = MonetaryAmount(currency: currency)
    }
}

// MARK: - IMonetaryAmountInputProxy conformance

extension MonetaryAmountInputProxy: IMonetaryAmountInputProxy {
    var amountAsString: String {
        get {
            let amount = monetaryAmount.amount
            if amount == 0.0 { return "" }
            var res = "\(amount)"
            // Adds a trailing separator if flag set to true
            if shouldAddTrailingSeparator { res += separator }
            // Adds a separator if fractional part consists of only trailing zeros
            if (amountOfTrailingZeros > 0 && amount.rounded(scale: 0) == amount) { res += separator }
            // Adds the required amount of trailing zeros
            res += Array(repeating: "0", count: amountOfTrailingZeros)
            return res
        }

        set {
            let previousValue = monetaryAmount
            let currency = previousValue.currency
            let roundingScale = currency.roundingScale
            // Fallback: sets the amount to the previous value to trigger publisher
            let fallback = { [weak self] in self?.monetaryAmount = previousValue }
            // For an empty string, sets the value to 0.0
            guard newValue != "" else { monetaryAmount = MonetaryAmount(currency: currency); return }
            // Checks the input is a valid numeric input
            guard let properNumber = Double(newValue) else { fallback(); return }
            // Logic around fractional values of the decimal
            let splits = newValue.split(separator: separator, omittingEmptySubsequences: false)
            // Checks that the input will not overflow
            guard splits[0].count < 14 else { fallback(); return }
            if splits.count == 2, let last = newValue.last {
                // Forbids inputting more fractional digits than allowed for the currency
                guard splits[1].count <= roundingScale else { fallback(); return }
                // Sets trailing separator flag, so that the getter keeps it
                shouldAddTrailingSeparator = (String(last) == separator && roundingScale > 0) ? true : false
                // Sets the amount of trailing zeros, so that the getter keeps them
                amountOfTrailingZeros = String(splits[1]).amountOfTrailingZeros()
            } else {
                shouldAddTrailingSeparator = false
                amountOfTrailingZeros = 0
            }

            monetaryAmount = monetaryAmount.with(amount: Decimal(properNumber))
        }
    }

    var amountAsDecimal: Decimal {
        get { monetaryAmount.amount }
        set { monetaryAmount = monetaryAmount.with(amount: newValue) }
    }

    var currency: Currency {
        get { monetaryAmount.currency }
        set { monetaryAmount = monetaryAmount.with(currency: newValue) }
    }
}

// MARK: - Helpers

fileprivate extension String {
    func amountOfTrailingZeros() -> Int {
        var res = 0
        for c in self.reversed() {
            if c != "0" { break } else { res += 1 }
        }
        return res
    }
}
