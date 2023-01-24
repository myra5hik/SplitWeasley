//
//  MonetaryAmount.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/11/22.
//

import Foundation

struct MonetaryAmount: Equatable, Hashable {
    let currency: Currency
    let amount: Decimal

    init(currency: Currency, amount: Decimal = 0.0) {
        self.currency = currency
        self.amount = amount.rounded(scale: currency.roundingScale)
    }

    init(currency: Currency, amountAsDouble: Double) {
        self.init(currency: currency, amount: Decimal(amountAsDouble))
    }

    func with(
        currency: Currency? = nil,
        amount: Decimal? = nil
    ) -> Self {
        return .init(
            currency: currency ?? self.currency,
            amount: amount ?? self.amount
        )
    }

    func formatted() -> String {
        return amount.formatted(
            .currency(code: currency.iso4217code)
            .precision(.fractionLength(0...currency.roundingScale))
        )
    }
}
