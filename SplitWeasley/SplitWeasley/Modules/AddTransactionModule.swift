//
//  AddTransactionModule.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 06.01.2023.
//

import SwiftUI

protocol IAddTransactionModule {
    var rootView: AnyView { get }
}

final class AddTransactionModule: IAddTransactionModule {
    // Public
    var rootView: AnyView { presentingView.eraseToAnyView() }
    // Private
    private let transactionScreenViewModel = TransactionScreenViewModel()
    private let router = Router<AddTransactionModule>()
    private var presentingView: PresentingView<Router<AddTransactionModule>>!

    init() {
        self.presentingView = PresentingView(router: router, factory: self, root: .transactionScreen)
    }
}

// MARK: - Routing

extension AddTransactionModule {
    enum RoutingDestination: Identifiable, IRoutingDestination {
        var id: String { "\(self)" }

        case transactionScreen
        case categorySelector
        case splitStrategySelector
    }
}

// MARK: - IScreenFactory conformance

extension AddTransactionModule: IScreenFactory {
    func view(for destination: AddTransactionModule.RoutingDestination) -> AnyView {
        switch destination {
        case .transactionScreen: return makeTransactionScreen().eraseToAnyView()
        case .categorySelector: return makeCategorySelectorScreen().eraseToAnyView()
        case .splitStrategySelector: return makeSplitStrategySelectorScreen().eraseToAnyView()
        }
    }

    // MARK: - Make functions
    private func makeTransactionScreen() -> some View {
        return TransactionScreenView(vm: transactionScreenViewModel, router: router)
    }

    private func makeCategorySelectorScreen() -> some View {
        let cancelButton = Button("Cancel", role: .cancel) { [weak self] in
            self?.router.dismiss()
        }

        return NavigationView {
            TransactionCategorySelectionList { [weak self] (category) in
                self?.transactionScreenViewModel.transactionCategory = category
                self?.router.dismiss()
            }
            .navigationTitle("Select category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { cancelButton }
        }
    }

    private func makeSplitStrategySelectorScreen() -> some View {
        return SplitOptionsScreenView(
            splitGroup: SplitGroup.stub,
            total: transactionScreenViewModel.amount,
            initialState: transactionScreenViewModel.splitStrategy,
            onDismiss: { [weak self] in self?.router.dismiss() },
            onDone: { [weak self] in self?.transactionScreenViewModel.splitStrategy = $0; self?.router.dismiss() }
        )
    }
}
