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
        applyingNavigationModifiers {
            ScrollView {
                LazyVStack {
                    GroupSummaryLayoverView(balances: balances).padding()
                    ForEach(transactions) { transaction in
                        cell(for: transaction)
                    }
                }
            }
        }
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
        if transaction.paidBy.keys.count == 1 {
            guard let payee = transaction.paidBy.keys.first else { assertionFailure(); return nil }
            if payee == currentUser { return .currentUser }
            // TODO: Resolve other's name 
            return .other(name: "Other person")
        } else {
            return .multiplePeople
        }
    }

    // MARK: Navigation and Toolbar

    private func applyingNavigationModifiers(_ view: () -> some View) -> some View {
        view()
            .navigationTitle("Trip to Turkey")
            .toolbar { addToolbarButton }
    }

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
                    .init(currency: .eur, amount: 102.12),
                    .init(currency: .chf, amount: 23),
                    .init(currency: .krw, amount: -10_092_793)
                ],
                transactions: SplitTransaction.stub,
                currentUser: SplitGroup.stub.members[0].id
            )
        }
    }
}
