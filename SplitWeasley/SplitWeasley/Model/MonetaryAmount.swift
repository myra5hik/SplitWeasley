//
//  MonetaryAmount.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/11/22.
//

import Foundation

struct MonetaryAmount {
    let currency: Currency
    var amount: Decimal

    func with(_ currency: Currency) -> Self {
        return .init(
            currency: currency,
            amount: self.amount
        )
    }
}
