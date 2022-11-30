//
//  PercentageSplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 29/11/22.
//

import Foundation

protocol IPercentageSplitStrategy: ObservableObject, ISplitStrategy where SplitParameter == Percent {
    typealias Percent = Decimal

    var inputAmount: [Person.ID: Percent] { get }
    var remainingAmount: Percent { get }
}

final class PercentageSplitStrategy: ObservableObject {
    // Public
    let splitGroup: SplitGroup
    var total: MonetaryAmount
    private(set) var inputAmount = [Person.ID: Percent]() {
        willSet { objectWillChange.send() }
        didSet { assignNewPersonBearingResidue() }
    }
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

    func set(_ value: Percent, for personId: Person.ID) {
        guard splitGroup.members.map({ $0.id }).contains(personId) else { return }
        inputAmount[personId] = value
    }
}

// MARK: - IPersentageSplitStrategy conformance

extension PercentageSplitStrategy: IPercentageSplitStrategy {
    var remainingAmount: Percent {
        1.0 - inputAmount.values.reduce(0.0, { $0 + $1 })
    }
}

// MARK: - Helpers

private extension PercentageSplitStrategy {
    var roundingResidue: MonetaryAmount {
        // If percentage split is not filled to 100%, does not return any rounding residue
        guard remainingAmount == 0.0 else { return MonetaryAmount(currency: total.currency) }

        let chargedTotal = splitGroup.members
            .map({ $0.id })
            .compactMap({ [weak self] in self?.rawAmount(for: $0)?.amount })
            .reduce(0, +)

        return MonetaryAmount(currency: total.currency, amount: total.amount - chargedTotal)
    }

    /// Amount not accounting for the complexity of rounding behavior (e.g. can result in 3.33 + 3.33 + 3.33 = 9.99 out of 10.0)
    func rawAmount(for personId: Person.ID) -> MonetaryAmount? {
        return MonetaryAmount(
            currency: total.currency,
            amount: inputAmount[personId, default: 0.0] * total.amount
        )
    }

    func assignNewPersonBearingResidue() {
        personBearingResidue = inputAmount.keys.filter({ inputAmount[$0] ?? 0 > 0 }).randomElement()
    }
}
