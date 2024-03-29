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
    private typealias VM = AddTransactionScreenViewModel<TransactionsService, StubUserService>
    // Public
    var rootView: AnyView { presentingView.eraseToAnyView() }
    // Private
    private let group: SplitGroup
    private var addTransactionScreenViewModel: VM
    private var presentingView: PresentingView<R, GroupTransactionsModule>!
    // Dependencies
    private let transactionsService = TransactionsService()
    private let userService = StubUserService()
    private let profilePictureService = StubAsyncProfilePictureService()
    private let router = R()

    init(group: SplitGroup) {
        self.group = group
        self.addTransactionScreenViewModel = AddTransactionScreenViewModel(
            group: group,
            transactionService: transactionsService,
            userService: userService
        )
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
        case payeeSelector
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
        case .payeeSelector: makePayeeSelectorScreen()
        case .transactionDetailView(id: let id): makeTransactionDetailScreen(id: id)
        }
    }

    // MARK: Make functions

    private func makeTransactionListScreen() -> some View {
        return GroupTransactionsScreenView(
            group: group,
            transactionsService: transactionsService,
            userService: userService,
            onTapOfAdd: { [weak self, group] in
                guard let self = self else { return }
                // Resets the view model to an empty one
                self.addTransactionScreenViewModel = AddTransactionScreenViewModel(
                    group: group,
                    transactionService: self.transactionsService,
                    userService: self.userService
                )
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
            profilePictureService: profilePictureService,
            onDismiss: { [weak self] in self?.router.dismiss() },
            onDone: { [weak self] in self?.addTransactionScreenViewModel.splitStrategy = $0; self?.router.dismiss() }
        )
    }

    private func makePayeeSelectorScreen() -> some View {
        return PayeeSelectScreenView(
            group: group,
            service: profilePictureService,
            onSelect: { [weak self] in self?.addTransactionScreenViewModel.payee = $0; self?.router.dismiss() },
            onTapOfCancel: { [weak self] in self?.router.dismiss() }
        )
    }

    private func makeTransactionDetailScreen(id: SplitTransaction.ID) -> some View {
        Text("Transaction Detail Screen Stub\nID = \(id)")
    }
}
