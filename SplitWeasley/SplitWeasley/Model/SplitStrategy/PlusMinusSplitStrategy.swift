//
//  PlusMinusSplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 02/12/22.
//

import Foundation

protocol IPlusMinusSplitStrategy: ISplitStrategy where SplitParameter == MonetaryAmount? {
    var adjustments: [Person.ID: MonetaryAmount] { get }
    var commonSharePerPerson: MonetaryAmount { get }
    func toggleInvolvement(for: Person.ID)
}

final class PlusMinusSplitStrategy: IPlusMinusSplitStrategy {
    // Public
    let splitGroup: SplitGroup
    var total: MonetaryAmount
    private(set) var adjustments: [Person.ID: MonetaryAmount] {
        willSet { objectWillChange.send() }
        didSet { assignNewPersonBearingResidue() }
    }
    var commonSharePerPerson: MonetaryAmount {
        MonetaryAmount(currency: total.currency, amount: commonPart / Decimal(countOfInvolved))
    }
    // Private
    /// The person who will bear the residue after splitting, when e.g. $10.0 is split within 3 people by $3.33
    private var personBearingResidue: Person.ID? = nil

    // Init
    init(splitGroup: SplitGroup, total: MonetaryAmount) {
        self.splitGroup = splitGroup
        self.total = total
        self.adjustments = [Person.ID: MonetaryAmount](
            uniqueKeysWithValues: splitGroup.members.map({ ($0.id, MonetaryAmount(currency: total.currency)) })
        )
        assignNewPersonBearingResidue()
    }
}

// MARK: - Logics

extension PlusMinusSplitStrategy {
    var isLogicallyConsistent: Bool { adjustments.keys.count > 0 && sumOfAdjustments <= total.amount }
}

// MARK: - Data manipulation

extension PlusMinusSplitStrategy {
    private var roundingScale: Int { total.currency.roundingScale }
    private var sumOfAdjustments: Decimal { adjustments.values.map({ $0.amount }).reduce(0.0, { $0 + $1 }) }
    private var countOfInvolved: Int { adjustments.keys.count }
    private var commonPart: Decimal { total.amount - sumOfAdjustments }
    /// The amount left after splitting and rounding, like when 10.0 is divided between 3 people (10.0 - 9.99 = 0.01)
    private var residue: Decimal? {
        guard countOfInvolved > 0 else { return nil }
        return total.amount - adjustments.keys.compactMap(rawAmount(_:)).reduce(0.0, { $0 + $1 })
    }

    func amount(for personId: Person.ID) -> MonetaryAmount? {
        guard let rawAmount = rawAmount(personId) else { return nil }
        let chargedResidue = (personBearingResidue == personId) ? (residue ?? 0.0) : 0.0

        return MonetaryAmount(
            currency: total.currency,
            amount: rawAmount + chargedResidue
        )
    }

    func set(_ adjustment: MonetaryAmount?, for personId: Person.ID) {
        guard splitGroup.members.map({ $0.id }).contains(personId) else { return }
        adjustments[personId] = adjustment
    }

    func toggleInvolvement(for personId: Person.ID) {
        if adjustments[personId] != nil {
            adjustments[personId] = nil
        } else {
            adjustments[personId] = MonetaryAmount(currency: total.currency)
        }
    }
}

// MARK: - Helpers

private extension PlusMinusSplitStrategy {
    private func assignNewPersonBearingResidue() {
        personBearingResidue = adjustments.keys.randomElement()
    }
    /// Amount not accounting for the complexity of rounding behavior (e.g. can result in 3.33 + 3.33 + 3.33 = 9.99 out of 10.0)
    private func rawAmount(_ memberId: Person.ID) -> Decimal? {
        guard adjustments.keys.contains(memberId) else { return nil }
        let chargedCommonShare = commonPart / Decimal(countOfInvolved)
        let chargedAdjustment = adjustments[memberId]?.amount ?? 0.0
        return (chargedCommonShare + chargedAdjustment).rounded(scale: roundingScale)
    }
}

// MARK: - Descriptions

extension PlusMinusSplitStrategy {
    // Descriptions
    var hintHeader: String { "Split by adjustment" }
    var hintDescription: String { "Enter adjustments to reflect who owes extra:" }
    var conciseHintDescription: String { "unequally" }
}
