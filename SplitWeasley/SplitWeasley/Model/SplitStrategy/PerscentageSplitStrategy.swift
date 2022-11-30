//
//  PerscentageSplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 29/11/22.
//

import Foundation

protocol IPersentageSplitStrategy: ObservableObject, ISplitStrategy {
    typealias Percent = Decimal

    var inputAmount: [Person.ID: Percent] { get set }
    var inputTotal: Percent { get }
    var remainingAmount: Percent { get }
}

final class PercentageSplitStrategy: ObservableObject {
    // Public
    @Published var inputAmount = [Person.ID: Percent]() {
        didSet { personBearingResidue = inputAmount.keys.filter({ inputAmount[$0] ?? 0 > 0 }).randomElement() }
    }
    let splitGroup: SplitGroup
    var total: MonetaryAmount
    // Private
    private var personBearingResidue: Person.ID?

    init(splitGroup: SplitGroup, total: MonetaryAmount) {
        self.splitGroup = splitGroup
        self.total = total
    }
}

// MARK: - ISplitStrategy conformance

extension PercentageSplitStrategy: ISplitStrategy {
    var isLogicallyConsistent: Bool {
        return remainingAmount == 0.0
    }

    // Descriptions
    var hintHeader: String { "Split by percentages" }
    var hintDescription: String { "Specify the split as percent of total:" }
    var conciseHintDescription: String { "unequally" }

    func amount(for personId: Person.ID) -> MonetaryAmount? {
        let chargedResidue = (personId == personBearingResidue) ? roundingResidue.amount : 0.0
        return MonetaryAmount(
            currency: total.currency,
            amount: total.amount * (inputAmount[personId] ?? 0.0) + chargedResidue
        )
    }
}

// MARK: - IPersentageSplitStrategy conformance

extension PercentageSplitStrategy: IPersentageSplitStrategy {
    var inputTotal: Percent {
        inputAmount.values.reduce(0.0, { $0 + $1 })
    }

    var remainingAmount: Percent {
        1.0 - inputTotal
    }
}

// MARK: - Helpers

private extension PercentageSplitStrategy {
    private var roundingResidue: MonetaryAmount {
        // If percentage split is not filled to 100%, does not return any rounding residue
        guard remainingAmount == 0.0 else { return MonetaryAmount(currency: total.currency) }

        let chargedTotal = splitGroup.members
            .map({ $0.id })
            .compactMap({ [weak self] in self?.rawAmount(for: $0)?.amount })
            .reduce(0, +)

        return MonetaryAmount(currency: total.currency, amount: total.amount - chargedTotal)
    }

    /// Amount not accounting for the complexity of rounding behavior (e.g. can result in 3.33 + 3.33 + 3.33 = 9.99 out of 10.0)
    private func rawAmount(for personId: Person.ID) -> MonetaryAmount? {
        return MonetaryAmount(
            currency: total.currency,
            amount: inputAmount[personId, default: 0.0] * total.amount
        )
    }
}
