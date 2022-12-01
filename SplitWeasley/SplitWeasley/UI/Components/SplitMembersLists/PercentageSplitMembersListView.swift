//
//  PercentageSplitMembersListView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 01/12/22.
//

import SwiftUI

struct PercentageSplitMembersListView<S: IPercentageSplitStrategy>: View {
    @ObservedObject private var strategy: S

    init(strategy: S) {
        self.strategy = strategy
    }

    var body: some View {
        List {
            Section {
                ForEach(strategy.splitGroup.members, id: \.id) { member in
                    ConfugurableListRowView(
                        heading: member.fullName,
                        subheading: strategy.amount(for: member.id)?.formatted() ?? "",
                        leadingAccessory: { Circle().foregroundColor(.blue) },
                        trailingAccessory: { makeInputView(memberId: member.id) }
                    )
                }
            }
            leftToDistributeRow
        }
        .listStyle(.plain)
    }

    private var leftToDistributeRow: some View {
        ConfugurableListRowView(
            heading: "Left to Distribute:",
            leadingAccessory: { Rectangle().foregroundColor(Color(uiColor: .clear)) },
            trailingAccessory: {
                Text(strategy.remainingAmount.formatted(.percent))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        )
    }

    private func makeInputView(memberId: Person.ID) -> some View {
        let binding = Binding(
            get: { (strategy.inputAmount[memberId] ?? 0.0) * 100 },
            set: { strategy.set($0 / 100, for: memberId) }
        )
        return NumericInputView(binding, placeholder: "0.0", suffix: "%")
    }
}

struct PercentageSplitMembersListView_Previews: PreviewProvider {
    static var previews: some View {
        PercentageSplitMembersListView(strategy: PercentageSplitStrategy(
            splitGroup: SplitGroup.stub,
            total: MonetaryAmount(currency: .eur, amount: 10.0))
        )
    }
}
