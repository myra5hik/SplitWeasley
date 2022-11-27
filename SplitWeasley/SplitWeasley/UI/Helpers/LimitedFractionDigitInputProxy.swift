//
//  LimitedFractionDigitInputProxy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 22/11/22.
//

import SwiftUI

// MARK: - ILimitedFractionDigitInputProxy protocol

protocol ILimitedFractionDigitInputProxy: ObservableObject {
    var amountAsString: String { get set }
    var amountAsDecimal: Decimal { get set }
    var roundingScale: Int { get set }

    init(roundingScale: Int)
}

// MARK: - LimitedFractionDigitInputProxy implementation

///
/// A proxy wrapping a Decimal and exposing a String get/set binding with an equivalent value.
/// It will maintain an appropriate state for both variables, no matter the mutating direction.
/// Designed for binding TextFields onto an underlying numeric value without the need to use formatters, while providing optimal UX.
///
final class LimitedFractionDigitInputProxy: ObservableObject {
    private var decimal: Decimal = 0.0 {
        willSet { objectWillChange.send() }
    }
    // Inputs
    var roundingScale: Int {
        didSet { decimal = decimal.rounded(scale: roundingScale) }
    }
    private let separator = "\(Locale.current.decimalSeparator ?? "")"
    // Logics
    private var shouldAddTrailingSeparator = false
    private var amountOfTrailingZeros = 0

    init(roundingScale: Int) {
        self.roundingScale = roundingScale
    }
}

// MARK: - IMonetaryAmountInputProxy conformance

extension LimitedFractionDigitInputProxy: ILimitedFractionDigitInputProxy {
    var amountAsString: String {
        get {
            if decimal == 0.0 { return "" }
            var res = "\(decimal)"
            // Adds a trailing separator if flag set to true
            if shouldAddTrailingSeparator { res += separator }
            // Adds a separator if fractional part consists of only trailing zeros
            if (amountOfTrailingZeros > 0 && decimal.rounded(scale: 0) == decimal) { res += separator }
            // Adds the required amount of trailing zeros
            res += Array(repeating: "0", count: amountOfTrailingZeros)
            return res
        }

        set {
            let previousValue = decimal
            // Fallback: sets the amount to the previous value to trigger publisher
            let fallback = { [weak self] in self?.decimal = previousValue }
            // For an empty string, sets the value to 0.0
            guard newValue != "" else { decimal = 0.0; return }
            // Checks the input is a valid numeric input
            guard let properNumber = Double(newValue) else { fallback(); return }
            // Logic around fractional values of the decimal
            let splits = newValue.split(separator: separator, omittingEmptySubsequences: false)
            // Checks that the input will not overflow
            guard splits[0].count < 14 else { fallback(); return }
            if splits.count == 2, let last = newValue.last {
                // Forbids inputting more fractional digits than allowed
                guard splits[1].count <= roundingScale else { fallback(); return }
                // Sets trailing separator flag, so that the getter keeps it
                shouldAddTrailingSeparator = (String(last) == separator && roundingScale > 0) ? true : false
                // Sets the amount of trailing zeros, so that the getter keeps them
                amountOfTrailingZeros = String(splits[1]).amountOfTrailingZeros()
            } else {
                shouldAddTrailingSeparator = false
                amountOfTrailingZeros = 0
            }

            decimal = Decimal(properNumber)
        }
    }

    var amountAsDecimal: Decimal {
        get { decimal }
        set { decimal = newValue.rounded(scale: roundingScale) }
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
