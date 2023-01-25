//
//  GroupTransactionsModule.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 06.01.2023.
//

import SwiftUI

// MARK: - IGroupTransactionsModule protocol

protocol IGroupTransactionsModule {
    var rootView: AnyView { get }
}

// MARK: - GroupTransactionsModule Implementation

///
/// The module is responsible for ownership, view creation, dependency injection and setting up routing
///
final class GroupTransactionsModule: IGroupTransactionsModule {
    private typealias R = Router<RoutingDestination>
    // Public
    var rootView: AnyView { presentingView.eraseToAnyView() }
    // Private
    private var addTransactionScreenViewModel: AddTransactionScreenViewModel
    private let router = R()
    private var presentingView: PresentingView<R, GroupTransactionsModule>!
    // Data
    private let group: SplitGroup

    init(group: SplitGroup) {
        self.group = group
        self.addTransactionScreenViewModel = AddTransactionScreenViewModel(group: group)
        self.presentingView = PresentingView(router: router, factory: self, root: .transactionList)
    }
}

// MARK: - Routing

extension GroupTransactionsModule {
    enum RoutingDestination: IRoutingDestination {
        case transactionList
        case addTransactionScreen
        case categorySelector
        case splitStrategySelector
        case transactionDetailView(id: SplitTransaction.ID)
    }
}

extension GroupTransactionsModule.RoutingDestination: Identifiable {
    var id: String { "\(self)" }
}

// MARK: - IScreenFactory conformance

extension GroupTransactionsModule: IScreenFactory {
    typealias RD = RoutingDestination

    @ViewBuilder
    func view(for destination: GroupTransactionsModule.RoutingDestination) -> some View {
        switch destination {
        case .transactionList: makeTransactionListScreen()
        case .addTransactionScreen: makeAddTransactionScreen()
        case .categorySelector: makeCategorySelectorScreen()
        case .splitStrategySelector: makeSplitStrategySelectorScreen()
        case .transactionDetailView(id: let id): makeTransactionDetailScreen(id: id)
        }
    }

    // MARK: Make functions

    private func makeTransactionListScreen() -> some View {
        return GroupTransactionsScreenView(
            balances: [MonetaryAmount(currency: .eur, amount: 123.45)],
            transactions: SplitTransaction.stub,
            currentUser: SplitGroup.stub.members[0].id,
            onTapOfAdd: { [weak self, group] in
                guard let self = self else { return }
                // Resets the view model to an empty one
                self.addTransactionScreenViewModel = AddTransactionScreenViewModel(group: group)
                self.router.push(.addTransactionScreen)
            },
            onTapOfDetail: { [weak self] transactionId in
                self?.router.push(.transactionDetailView(id: transactionId))
            }
        )
    }

    private func makeAddTransactionScreen() -> some View {
        return AddTransactionScreenView(vm: addTransactionScreenViewModel, router: router)
    }

    private func makeCategorySelectorScreen() -> some View {
        let cancelButton = Button("Cancel", role: .cancel) { [weak self] in
            self?.router.dismiss()
        }

        return NavigationView {
            TransactionCategorySelectionList(onSelect: { [weak self] (category) in
                self?.addTransactionScreenViewModel.transactionCategory = category
                self?.router.dismiss()
            })
            .navigationTitle("Select category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { cancelButton }
        }
    }

    private func makeSplitStrategySelectorScreen() -> some View {
        return SplitOptionsScreenView(
            splitGroup: SplitGroup.stub,
            total: addTransactionScreenViewModel.amount,
            initialState: addTransactionScreenViewModel.splitStrategy,
            onDismiss: { [weak self] in self?.router.dismiss() },
            onDone: { [weak self] in self?.addTransactionScreenViewModel.splitStrategy = $0; self?.router.dismiss() }
        )
    }

    private func makeTransactionDetailScreen(id: SplitTransaction.ID) -> some View {
        Text("Transaction Detail Screen Stub\nID = \(id)")
    }
}
