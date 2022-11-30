//
//  EqualSharesSplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 23/11/22.
//

import Foundation

protocol IEqualSharesSplitStrategy: ISplitStrategy where SplitParameter == Bool {
    var isIncluded: [Person.ID: Bool] { get }
}

final class EqualSharesSplitStrategy: IEqualSharesSplitStrategy {
    // Public
    let splitGroup: SplitGroup
    var total: MonetaryAmount
    private(set) var isIncluded: [Person.ID: Bool] {
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
        self.isIncluded = [Person.ID: Bool](uniqueKeysWithValues: splitGroup.members.map { ($0.id, true) })
        assignNewPersonBearingResidue()
    }
}

// MARK: - Logics

extension EqualSharesSplitStrategy {
    var isLogicallyConsistent: Bool { includedCount >= 1 }
}

// MARK: - Data manipulation

extension EqualSharesSplitStrategy {
    private var roundingScale: Int { total.currency.roundingScale }
    private var includedCount: Int { isIncluded.values.filter({ $0 == true }).count }
    /// The amount left after splitting and rounding, like when 10.0 is divided between 3 people (10.0 - 9.99 = 0.01)
    private var residue: Decimal? {
        guard includedCount >= 1 else { return nil }
        let personalShare = (total.amount / Decimal(includedCount)).rounded(scale: roundingScale)
        return total.amount - personalShare * Decimal(includedCount)
    }

    func amount(for personId: Person.ID) -> MonetaryAmount? {
        guard includedCount >= 1 && isIncluded[personId] == true else { return nil }
        let chargedResidue = (personBearingResidue == personId) ? residue : 0
        return MonetaryAmount(
            currency: total.currency,
            amount: (total.amount / Decimal(includedCount)).rounded(scale: roundingScale) + (chargedResidue ?? 0)
        )
    }

    func set(_ included: Bool, for personId: Person.ID) {
        guard isIncluded.keys.contains(personId) else { return }
        isIncluded[personId] = included
    }
}

// MARK: - Helpers

private extension EqualSharesSplitStrategy {
    private func assignNewPersonBearingResidue() {
        personBearingResidue = isIncluded.keys.filter({ isIncluded[$0] == true }).randomElement()
    }
}

// MARK: - Descriptions

extension EqualSharesSplitStrategy {
    // Descriptions
    var hintHeader: String { "Split equally" }
    var hintDescription: String { "Select which people own an equal share:" }
    var conciseHintDescription: String { "equally" }
}
