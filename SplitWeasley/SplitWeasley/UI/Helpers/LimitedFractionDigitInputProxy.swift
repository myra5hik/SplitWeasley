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

    init(roundingScale: Int, initialValue: Decimal)
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
    private var shouldAddLeadingZero = false
    private var amountOfTrailingZeros = 0

    init(roundingScale: Int, initialValue: Decimal) {
        self.roundingScale = roundingScale
        self.decimal = initialValue
    }
}

// MARK: - IMonetaryAmountInputProxy conformance

extension LimitedFractionDigitInputProxy: ILimitedFractionDigitInputProxy {
    var amountAsString: String {
        get {
            var res = decimal == 0.0 ? "" : "\(decimal)"
            if shouldAddLeadingZero { res = "0\(res)" }
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
            // Checks that the input will not overflow
            guard newValue.count <= 16 else { fallback(); return }
            // For an empty string, sets the value to 0.0
            guard newValue != "" else { decimal = 0.0; shouldAddLeadingZero = false; return }
            // Logic around fractional values of the decimal
            let splits = newValue.split(separator: separator, omittingEmptySubsequences: false)
            guard splits.count >= 1 && splits.count <= 2 else { fallback(); return }
            let wholePart = splits[0]
            let fractionalPart = (splits.count == 2) ? splits[1] : nil
            // Sets flags which manage state not derivable from the numeric value
            shouldAddLeadingZero = (wholePart == "0" && (fractionalPart == "" || fractionalPart == nil))
            shouldAddTrailingSeparator = (fractionalPart == "" && roundingScale > 0)
            // Forbids inputting more fractional digits than allowed
            if splits.count == 2 && splits[1].count > roundingScale { fallback(); return }
            // Checks the input is a valid numeric input
            guard let properNumber = Decimal(string: newValue) else { fallback(); return }
            decimal = properNumber
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
