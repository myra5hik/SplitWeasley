//
//  UnequalSharesSplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 01/12/22.
//

import Foundation

protocol IUnequalSharesSplitStrategy: ISplitStrategy where SplitParameter == Int {
    var amountOfShares: [Person.ID: UInt] { get }
}

final class UnequalSharesSplitStrategy: IUnequalSharesSplitStrategy {
    // Public
    let splitGroup: SplitGroup
    var total: MonetaryAmount
    private(set) var amountOfShares: [Person.ID: UInt] {
        willSet { objectWillChange.send() }
        didSet { assignNewPersonBearingResidue() }
    }
    // Private
    /// The person who will bear the residue after splitting, when e.g. $10.0 is split within 3 people by $3.33
    private var personBearingResidue: Person.ID? = nil

    // Init
    init(splitGroup: SplitGroup, total: MonetaryAmount) {
        self.splitGroup = splitGroup
        self.total = total
        self.amountOfShares = [Person.ID: UInt](uniqueKeysWithValues: splitGroup.members.map({ ($0.id, 1) }))
        assignNewPersonBearingResidue()
    }
}

// MARK: - Logics

extension UnequalSharesSplitStrategy {
    var isLogicallyConsistent: Bool { totalShares >= 1 }
}

// MARK: - Data manipulation

extension UnequalSharesSplitStrategy {
    private var roundingScale: Int { total.currency.roundingScale }
    private var totalShares: UInt { amountOfShares.values.reduce(0, +) }
    /// The amount left after splitting and rounding, like when 10.0 is divided between 3 people (10.0 - 9.99 = 0.01)
    private var residue: Decimal? {
        guard totalShares > 0 else { return nil }
        return total.amount - amountOfShares.keys.map(rawAmount(_:)).reduce(0.0, +)
    }

    func amount(for personId: Person.ID) -> MonetaryAmount? {
        guard let amountOfShares = amountOfShares[personId], amountOfShares > 0 else { return nil }
        let chargedResidue = (personBearingResidue == personId) ? (residue ?? 0.0) : 0.0
        return MonetaryAmount(
            currency: total.currency,
            amount: rawAmount(personId) + chargedResidue
        )
    }

    func set(_ shares: Int, for personId: Person.ID) {
        guard amountOfShares.keys.contains(personId) else { return }
        amountOfShares[personId] = UInt(max(0, shares))
    }
}

// MARK: - Helpers

private extension UnequalSharesSplitStrategy {
    private func assignNewPersonBearingResidue() {
        personBearingResidue = amountOfShares.keys.filter({ (amountOfShares[$0] ?? 0) > 0 }).randomElement()
    }
    /// Amount not accounting for the complexity of rounding behavior (e.g. can result in 3.33 + 3.33 + 3.33 = 9.99 out of 10.0)
    private func rawAmount(_ memberId: Person.ID) -> Decimal {
        guard totalShares > 0 else { return 0.0 }
        let amountOfShares = Decimal(amountOfShares[memberId] ?? 0)
        let singleShare = total.amount / Decimal(totalShares)
        return (singleShare * amountOfShares).rounded(scale: roundingScale)
    }
}

// MARK: - Descriptions

extension UnequalSharesSplitStrategy {
    // Descriptions
    var hintHeader: String { "Split by unequal shares" }
    var hintDescription: String { "Select how many shares each person owes:" }
    var conciseHintDescription: String { "unequally" }
}
