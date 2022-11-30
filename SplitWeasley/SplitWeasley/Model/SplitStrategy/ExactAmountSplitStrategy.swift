//
//  ExactAmountSplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 23/11/22.
//

import Foundation

protocol IExactAmountSplitStrategy: ObservableObject, ISplitStrategy where SplitParameter == MonetaryAmount {
    var remainingAmount: MonetaryAmount { get }
}

final class ExactAmountSplitStrategy: ObservableObject {
    // Public
    let splitGroup: SplitGroup
    var total: MonetaryAmount
    // Private
    private var inputAmount: [Person.ID: MonetaryAmount] {
        willSet { objectWillChange.send() }
    }

    init(splitGroup: SplitGroup, total: MonetaryAmount) {
        self.splitGroup = splitGroup
        self.total = total
        self.inputAmount = [Person.ID: MonetaryAmount](
            uniqueKeysWithValues: (splitGroup.members.map({ ($0.id, total.with(amount: 0.0)) }))
        )
    }
}

// MARK: - IExactAmountSplitStrategy conformance

extension ExactAmountSplitStrategy: IExactAmountSplitStrategy {
    // Descriptions
    var hintHeader: String { "Split by exact amounts" }
    var hintDescription: String { "Specify exactly how much a person owes:" }
    var conciseHintDescription: String { "unequally" }

    var inputTotal: MonetaryAmount {
        let currency = total.currency
        let inputTotal = inputAmount.values.reduce(MonetaryAmount(currency: currency), {
            assert($0.currency == currency && $1.currency == currency)
            return MonetaryAmount(currency: currency, amount: $0.amount + $1.amount)
        })
        return inputTotal
    }

    var remainingAmount: MonetaryAmount {
        return MonetaryAmount(currency: total.currency, amount: total.amount - inputTotal.amount)
    }

    var isLogicallyConsistent: Bool {
        return remainingAmount.amount == 0
    }

    func amount(for personId: Person.ID) -> MonetaryAmount? {
        return inputAmount[personId]
    }

    func set(_ value: MonetaryAmount, for personId: Person.ID) {
        guard inputAmount.keys.contains(personId) else { return }
        guard value.currency == total.currency else { return }
        inputAmount[personId] = value
    }
}
