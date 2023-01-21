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
    // Actions
    private let onTapOfAdd: (() -> Void)?

    init(balances: [MonetaryAmount], onTapOfAdd: (() -> Void)? = nil) {
        self.balances = balances
        self.onTapOfAdd = onTapOfAdd
    }

    var body: some View {
        applyingNavigationModifiers {
            ScrollView {
                LazyVStack {
                    GroupSummaryLayoverView(balances: balances).padding()
                }
            }
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
            GroupTransactionsScreenView(balances: [
                .init(currency: .eur, amount: 102.12),
                .init(currency: .chf, amount: 23),
                .init(currency: .krw, amount: -10_092_793)
            ])
        }
    }
}
