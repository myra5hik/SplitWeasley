//
//  Decimal+Rounded.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 22/11/22.
//

import Foundation

extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var initial = self
        var res = self
        NSDecimalRound(&res, &initial, scale, .plain)
        return res
    }
}
