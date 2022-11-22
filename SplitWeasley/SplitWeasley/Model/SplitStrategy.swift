//
//  SplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 21/11/22.
//

import Foundation

protocol ISplitStrategy: ObservableObject {
    /// Signifies that the applied parameters are consistent with the logic of the app. If false, views should not allow for further processing.
    var isLogicallyConsistent: Bool { get }
    /// Heading used by views to describe the split strategy
    var hintHeader: String { get }
    /// Text body used by views to describe the split strategy
    var hintDescription: String { get }
    /// One-word stretegy description used by views
    var conciseHintDescription: String { get }
    // Init
    init(splitGroup: SplitGroup, total: MonetaryAmount)
    /// Returns the amount split towards the person passed as parameter.
    func amount(for personId: Person.ID) -> MonetaryAmount?
}

// MARK: - EqualSharesSplitStrategy

protocol IEqualSharesSplitStrategy: ISplitStrategy {
    var isIncluded: [Person.ID: Bool] { get set }
}

final class EqualSharesSplitStrategy: IEqualSharesSplitStrategy {
    // Inputs
    @Published var isIncluded: [Person.ID: Bool] {
        didSet { personBearingResidue = isIncluded.keys.filter({ isIncluded[$0] == true }).randomElement() }
    }
    private let splitGroup: SplitGroup
    private let total: MonetaryAmount
    private var roundingScale: Int { total.currency.roundingScale }
    // Logics
    var isLogicallyConsistent: Bool { includedCount >= 1 }
    private var includedCount: Int { isIncluded.values.filter({ $0 == true }).count }
    /// The amount left after splitting and rounding, like when 10.0 is divided between 3 people (10.0 - 9.99 = 0.01)
    private var residue: Decimal? {
        guard includedCount >= 1 else { return nil }
        let personalShare = (total.amount / Decimal(includedCount)).rounded(scale: roundingScale)
        return total.amount - personalShare * Decimal(includedCount)
    }
    /// The person who will bear the residue after splitting
    private var personBearingResidue: Person.ID? = nil
    // Descriptions
    var hintHeader: String { "Split equally" }
    var hintDescription: String { "Select which people own an equal share:" }
    var conciseHintDescription: String { "equally" }
    // Init
    init(splitGroup: SplitGroup, total: MonetaryAmount) {
        self.splitGroup = splitGroup
        self.total = total
        self.isIncluded = [Person.ID: Bool](uniqueKeysWithValues: splitGroup.members.map { ($0.id, true) })
        personBearingResidue = isIncluded.keys.filter({ isIncluded[$0] == true }).randomElement()
    }

    func amount(for personId: Person.ID) -> MonetaryAmount? {
        guard includedCount >= 1 && isIncluded[personId] == true else { return nil }
        let chargedResidue = (personBearingResidue == personId) ? residue : 0
        return MonetaryAmount(
            currency: total.currency,
            amount: (total.amount / Decimal(includedCount)).rounded(scale: roundingScale) + (chargedResidue ?? 0)
        )
    }
}
