//
//  GroupTransactionsScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/01/23.
//

import SwiftUI

struct GroupTransactionsScreenView: View {
    let balances: [MonetaryAmount]

    var body: some View {
        applyingNavigationModifiers {
            List {
                GroupSummaryLayoverView(balances: balances).listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }

    private func applyingNavigationModifiers(_ view: () -> some View) -> some View {
        view()
            .navigationTitle("Trip to Turkey")
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
