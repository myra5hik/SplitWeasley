//
//  SplitTransaction.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 28/11/22.
//

import Foundation

struct SplitTransaction: Identifiable, Hashable {
    let id = UUID()

    let group: SplitGroup
    let total: MonetaryAmount
    let splits: [Person.ID: MonetaryAmount]
    let description: String
    let dateAdded: Date
    let datePerformed: Date

    var isLogicallyConsistent: Bool {
        guard
            // Checks total is equal to the sum of members' shares
            splits.values.map({ $0.amount }).reduce(0, +) == total.amount,
            // Checks all amounts are in the same currency
            splits.values.map({ $0.currency }).reduce(into: Set<Currency>(), { $0.insert($1) }).count < 2,
            splits.isEmpty || splits.values.first?.currency == total.currency,
            // Checks all people in splits are present in the group
            splits.keys.map({ group.members.map({ $0.id }).contains($0) }).reduce(true, { $0 && $1 })
        else { return false }
        return true
    }

    init(
        group: SplitGroup,
        total: MonetaryAmount,
        splits: [Person.ID: MonetaryAmount],
        description: String,
        dateAdded: Date,
        datePerformed: Date
    ) {
        self.group = group
        self.total = total
        self.splits = splits
        self.description = description
        self.dateAdded = Date()
        self.datePerformed = datePerformed
    }

    func with(
        total: MonetaryAmount? = nil,
        splits: [Person.ID: MonetaryAmount]? = nil,
        description: String? = nil,
        dateAdded: Date? = nil,
        datePerformed: Date? = nil
    ) -> SplitTransaction {
        .init(
            group: self.group,
            total: total ?? self.total,
            splits: splits ?? self.splits,
            description: description ?? self.description,
            dateAdded: dateAdded ?? self.dateAdded,
            datePerformed: datePerformed ?? self.datePerformed
        )
    }
}
