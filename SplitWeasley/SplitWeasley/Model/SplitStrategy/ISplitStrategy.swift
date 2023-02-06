//
//  ISplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 21/11/22.
//

import Foundation

protocol ISplitStrategy: ObservableObject {
    associatedtype SplitParameter

    // Data
    var splitGroup: SplitGroup { get }
    var total: MonetaryAmount { get set }

    // Logics
    /// Signifies that the applied parameters are consistent with the logic of the app. If false, views should not allow for further processing.
    var isLogicallyConsistent: Bool { get }

    // Descriptions
    /// Heading used by views to describe the split strategy
    var hintHeader: String { get }
    /// Text body used by views to describe the split strategy
    var hintDescription: String { get }
    /// One-word stretegy description used by views
    var conciseHintDescription: String { get }

    // Init
    init(splitGroup: SplitGroup, total: MonetaryAmount)

    // Data reads
    /// Returns the amount split towards the person passed as parameter.
    func amount(for personId: Person.ID) -> MonetaryAmount?
    var splits: [Person.ID: MonetaryAmount] { get }

    // Data manipulations
    /// Sets split parameter for the person
    func set(_ value: SplitParameter, for personId: Person.ID)
}

// MARK: - Default Implementation 

extension ISplitStrategy {
    var splits: [Person.ID: MonetaryAmount] {
        var res = [Person.ID: MonetaryAmount]()
        for personId in splitGroup.members.map(\.id) {
            res[personId] = amount(for: personId)
        }
        return res
    }
}
