//
//  MonetaryAmountInputProxy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 22/11/22.
//

import SwiftUI

protocol IMonetaryAmountInputProxy {
    var transactionAmount: String { get set }
    var transactionCurrency: Currency { get set }
}

final class MonetaryAmountInputProxy {
    // TODO: Rework with a @Binding instead of closures
    // Managed property
    private let getter: () -> (MonetaryAmount)
    private let setter: (MonetaryAmount) -> ()
    // Inputs
    private let separator = "\(Locale.current.decimalSeparator ?? "")"
    // Logics
    private var shouldAddTrailingSeparator = false
    private var amountOfTrailingZeros = 0

    init(
        managedPropertyGetter: @escaping () -> (MonetaryAmount),
        managedPropertySetter: @escaping (MonetaryAmount) -> ()
    ) {
        self.getter = managedPropertyGetter
        self.setter = managedPropertySetter
    }
}

extension MonetaryAmountInputProxy: IMonetaryAmountInputProxy {
    var transactionAmount: String {
        get {
            let amount = getter().amount
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
            let previousValue = getter()
            let roundingScale = previousValue.currency.roundingScale
            // Fallback: sets the amount to the previous value to trigger publisher
            let fallback = { [weak self] in
                guard let self = self else { return }
                self.setter(previousValue)
            }
            // For an empty string, sets the value to 0.0
            if newValue == "" { setter(previousValue.with(amount: 0.0)) }
            // Checks the input is a valid numeric input
            guard let properNumber = Double(newValue) else { fallback(); return }
            // Logic around fractional values of the decimal
            let splits = newValue.split(separator: separator, omittingEmptySubsequences: false)
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

            setter(previousValue.with(amount: Decimal(properNumber)))
        }
    }

    var transactionCurrency: Currency {
        get { getter().currency }
        set(newCurrency) { setter(getter().with(currency: newCurrency)) }
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
