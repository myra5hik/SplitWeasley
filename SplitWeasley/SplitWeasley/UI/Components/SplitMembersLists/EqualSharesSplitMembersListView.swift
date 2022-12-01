//
//  EqualSharesSplitMembersListView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 01/12/22.
//

import SwiftUI

struct EqualSharesSplitMembersListView<S: IEqualSharesSplitStrategy>: View {
    @ObservedObject private var strategy: S

    init(strategy: S) {
        self.strategy = strategy
    }

    var body: some View {
        List(strategy.splitGroup.members, id: \.id) { member in
            ConfugurableListRowView(
                heading: member.fullName,
                subheading: strategy.amount(for: member.id)?.formatted() ?? "not involved",
                leadingAccessory: { Circle().foregroundColor(.blue) },
                trailingAccessory: {
                    if strategy.isIncluded[member.id] ?? false {
                        Image(systemName: "checkmark")
                    }
                },
                action: {
                    let isIncluded = strategy.isIncluded[member.id] ?? false
                    strategy.set(!isIncluded, for: member.id)
                }
            )
            .frame(height: 38)
        }
        .listStyle(.plain)
    }
}

struct EqualSharesSplitMembersListView_Previews: PreviewProvider {
    static var previews: some View {
        EqualSharesSplitMembersListView(strategy: EqualSharesSplitStrategy(
            splitGroup: SplitGroup.stub,
            total: MonetaryAmount(currency: .eur, amount: 10.0))
        )
    }
}
