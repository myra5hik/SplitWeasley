//
//  GroupTransactionsScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/01/23.
//

import SwiftUI

struct GroupTransactionsScreenView: View {
    // Data
    private let balances: [MonetaryAmount]
    private let transactions: [SplitTransaction]
    // Dependencies
    private let currentUser: Person.ID
    // Actions
    private let onTapOfAdd: (() -> Void)?

    init(
        balances: [MonetaryAmount],
        transactions: [SplitTransaction],
        currentUser: Person.ID,
        onTapOfAdd: (() -> Void)? = nil
    ) {
        self.balances = balances
        self.transactions = transactions
        self.currentUser = currentUser
        self.onTapOfAdd = onTapOfAdd
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                // Summary
                GroupSummaryOverlayView(balances: balances)
                    .padding([.horizontal, .top])
                // Transactions
                ForEach(transactions, content: { cell(for: $0) })
                    .padding(.horizontal)
                    // Extra padding to align balance text vs. the summary overlay
                    .padding(.trailing, 6)
            }
        }
        .navigationTitle("Trip to Turkey")
        .toolbar { addToolbarButton }
    }

    // MARK: Components

    private func cell(for transaction: SplitTransaction) -> some View {
        guard let paidByDescriptor = paidByDescriptor(for: transaction) else {
            return EmptyView().eraseToAnyView()
        }

        let splitShare: Decimal = {
            guard
                transaction.total.amount != 0.0,
                let split = transaction.splits[currentUser]?.amount
            else { return 0.0 }
            return split / transaction.total.amount
        }()

        return TransactionCell(
            description: transaction.description,
            category: transaction.category,
            total: transaction.total,
            balance: transaction.balance(of: currentUser),
            paidBy: paidByDescriptor,
            currentUserSplitShare: splitShare
        )
        .eraseToAnyView()
    }

    // MARK: View Helpers

    private func paidByDescriptor(for transaction: SplitTransaction) -> TransactionCell.PaidByDescriptor? {
        guard transaction.paidBy.keys.count > 0 else { assertionFailure(); return nil }
        // Multiple people
        if transaction.paidBy.keys.count > 1 { return .multiplePeople }
        // Current user
        guard let payee = transaction.paidBy.keys.first else { assertionFailure(); return nil }
        if payee == currentUser { return .currentUser }
        // Other person
        guard let other = transaction.group.members.first(where: { $0.id == payee }) else {
            assertionFailure()
            return .other(name: "Other person")
        }
        return .other(name: other.shortenedFullName)
    }

    // MARK: Navigation and Toolbar

    private var addToolbarButton: some View {
        let handler = onTapOfAdd ?? { }
        return Button(action: handler) {
            Image(systemName: "plus")
        }
    }
}

// MARK: - Previews

struct GroupTransactionsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroupTransactionsScreenView(
                balances: [
                    .init(currency: .eur, amount: 102.12)
                ],
                transactions: SplitTransaction.stub,
                currentUser: SplitGroup.stub.members[0].id
            )
        }
    }
}
