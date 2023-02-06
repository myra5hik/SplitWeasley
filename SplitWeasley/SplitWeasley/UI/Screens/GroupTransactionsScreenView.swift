//
//  GroupTransactionsScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/01/23.
//

import SwiftUI

struct GroupTransactionsScreenView<TS: ITransactionsService, US: IUserService>: View {
    // Data
    @ObservedObject private var subscription: TS.ObservableBox
    private var currentUser: Person.ID { userService.currentUser.id }
    // Dependencies
    private let transactionService: TS
    private let userService: US
    // Actions
    private let onTapOfAdd: (() -> Void)?
    private let onTapOfDetail: ((SplitTransaction.ID) -> Void)?

    init(
        group: SplitGroup,
        transactionsService: TS,
        userService: US,
        onTapOfAdd: (() -> Void)? = nil,
        onTapOfDetail: ((SplitTransaction.ID) -> Void)? = nil
    ) {
        self.transactionService = transactionsService
        self.subscription = transactionService.subscribe(to: group.id)
        self.userService = userService
        self.onTapOfAdd = onTapOfAdd
        self.onTapOfDetail = onTapOfDetail
    }

    var body: some View {
        ScrollableLazyVStack {
            // Summary
            GroupSummaryOverlayView(balances: subscription.balances[currentUser] ?? [])
                .padding(.horizontal)
                .padding(.vertical, 6)
            // Transactions
            ForEach(subscription.groupings.sorted(by: { $0.key >= $1.key }), id: \.key) { (date, transactions) in
                Section(content: {
                    ForEach(transactions) { cell(for: $0) }
                }, header: {
                    header(for: date)
                })
            }
        }
        // Navigation
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
            currentUserSplitShare: splitShare,
            onTap: { onTapOfDetail?(transaction.id) }
        )
        .frame(height: 50)
        .padding(.horizontal)
        .padding(.top, 12)
        .eraseToAnyView()
    }

    private func header(for date: Date) -> some View {
        let dateFormatted = date.formatted(.dateTime.weekday(.wide).day().month())

        return Text(dateFormatted.uppercased())
            .font(.subheadline)
            .foregroundColor(Color(uiColor: .systemGray))
            .padding(.top)
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
                group: SplitGroup.stub,
                transactionsService: StubTransactionsService(),
                userService: StubUserService()
            )
        }
    }
}
