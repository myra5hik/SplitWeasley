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
    let paidBy: [Person.ID: MonetaryAmount]
    let splits: [Person.ID: MonetaryAmount]
    let description: String
    let dateAdded: Date
    let datePerformed: Date

    // MARK: Init

    init(
        group: SplitGroup,
        total: MonetaryAmount,
        paidBy: [Person.ID: MonetaryAmount],
        splits: [Person.ID: MonetaryAmount],
        description: String,
        dateAdded: Date,
        datePerformed: Date
    ) {
        self.group = group
        self.total = total
        self.paidBy = paidBy
        self.splits = splits
        self.description = description
        self.dateAdded = Date()
        self.datePerformed = datePerformed
    }
}

// MARK: - Computables

extension SplitTransaction {
    var isLogicallyConsistent: Bool {
        guard
            // Checks total is equal to the sum of members' shares
            splits.values.map({ $0.amount }).reduce(0, +) == total.amount,
            // Checks all amounts are in the same currency
            splits.values.map({ $0.currency }).reduce(into: Set<Currency>(), { $0.insert($1) }).count == 1,
            splits.isEmpty || splits.values.first?.currency == total.currency,
            paidBy.values.map({ $0.currency }).reduce(into: Set<Currency>(), { $0.insert($1) }).count == 1,
            paidBy.isEmpty || paidBy.values.first?.currency == total.currency,
            // Checks all people in splits are present in the group
            splits.keys.map({ group.members.map({ $0.id }).contains($0) }).reduce(true, { $0 && $1 })
        else { return false }
        return true
    }

    ///
    /// Returns a net outstanding balance of a person, by accounting for both 'paid by' and 'splits' values.
    /// 
    /// Paid by user: $10, Split: $3.33 => Balance: +$6.67
    ///
    /// Paid by other user: $10, Split: $3.33 => Balance: -$3.33
    ///
    /// Returns 'nil' if the given user is not involved in the transaction.
    ///
    func balance(of member: Person.ID) -> MonetaryAmount? {
        assert(isLogicallyConsistent)

        let splitTowardsCurrentUser = splits[member]?.amount
        let paidByCurrentUser = paidBy[member]?.amount
        if splitTowardsCurrentUser == nil && paidByCurrentUser == nil { return nil }
        let balance = (paidByCurrentUser ?? 0.0) - (splitTowardsCurrentUser ?? 0.0)

        return MonetaryAmount(
            currency: total.currency,
            amount: balance
        )
    }
}

// MARK: - Mutators

extension SplitTransaction {
    func with(
        total: MonetaryAmount? = nil,
        paidBy: [Person.ID: MonetaryAmount]? = nil,
        splits: [Person.ID: MonetaryAmount]? = nil,
        description: String? = nil,
        dateAdded: Date? = nil,
        datePerformed: Date? = nil
    ) -> SplitTransaction? {
        .init(
            group: self.group,
            total: total ?? self.total,
            paidBy: paidBy ?? self.paidBy,
            splits: splits ?? self.splits,
            description: description ?? self.description,
            dateAdded: dateAdded ?? self.dateAdded,
            datePerformed: datePerformed ?? self.datePerformed
        )
    }
}
