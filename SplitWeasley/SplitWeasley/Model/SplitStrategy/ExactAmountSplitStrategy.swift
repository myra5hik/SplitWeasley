//
//  ExactAmountSplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 23/11/22.
//

import Foundation

protocol IExactAmountSplitStrategy: ObservableObject, ISplitStrategy {
    var inputAmount: [Person.ID: MonetaryAmount] { get set }
}

final class ExactAmountSplitStrategy: ObservableObject {
    @Published var inputAmount: [Person.ID: MonetaryAmount]
    private let splitGroup: SplitGroup
    private let total: MonetaryAmount

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

    var isLogicallyConsistent: Bool {
        let currency = total.currency
        let inputTotal = inputAmount.values.reduce(MonetaryAmount(currency: currency), {
            assert($0.currency == currency && $1.currency == currency)
            return MonetaryAmount(currency: currency, amount: $0.amount + $1.amount)
        })
        return inputTotal == total
    }

    func amount(for personId: Person.ID) -> MonetaryAmount? {
        return inputAmount[personId]
    }
}
