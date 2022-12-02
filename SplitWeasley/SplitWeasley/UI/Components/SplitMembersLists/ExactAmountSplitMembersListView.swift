//
//  ExactAmountSplitMembersListView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 01/12/22.
//

import SwiftUI

struct ExactAmountSplitMembersListView<S: IExactAmountSplitStrategy>: View {
    @ObservedObject private var strategy: S
    @FocusState private var focus: Person.ID?

    init(strategy: S) {
        self.strategy = strategy
    }

    var body: some View {
        List {
            Section {
                ForEach(strategy.splitGroup.members, id: \.id) { member in
                    ConfugurableListRowView(
                        heading: member.fullName,
                        subheading: makeSubheading(memberId: member.id),
                        leadingAccessory: { Circle().foregroundColor(.blue) },
                        trailingAccessory: { makeInputView(memberId: member.id) },
                        action: { focus = member.id } // On tap on the cell, focuses onto TextField
                    )
                    .frame(height: 38)
                }
            }
            leftToDistributeRow.frame(height: 38)
        }
        .listStyle(.plain)
    }

    private var leftToDistributeRow: some View {
        ConfugurableListRowView(
            heading: "Left to Distribute:",
            leadingAccessory: { Rectangle().foregroundColor(Color(uiColor: .clear)) },
            trailingAccessory: {
                Text(strategy.remainingAmount.formatted())
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        )
    }

    private func makeSubheading(memberId: Person.ID) -> String {
        let amount = strategy.amount(for: memberId)?.amount ?? 0.0
        let total = strategy.total.amount
        let share = amount / total
        return share.formatted(.percent.precision(.fractionLength(0...2)))
    }

    private func makeInputView(memberId: Person.ID) -> some View {
        let currency = strategy.total.currency
        let defaultValue = MonetaryAmount(currency: currency)
        let binding = Binding(
            get: { (strategy.amount(for: memberId) ?? defaultValue).amount },
            set: { strategy.set(MonetaryAmount(currency: currency, amount: $0), for: memberId) }
        )
        // Return view
        return NumericInputView(
            binding,
            roundingScale: currency.roundingScale,
            placeholder: "\(MonetaryAmount(currency: currency).formatted())"
        )
        .multilineTextAlignment(.trailing)
        .focused($focus, equals: memberId)
    }
}

struct ExactAmountSplitMembersListView_Previews: PreviewProvider {
    static var previews: some View {
        ExactAmountSplitMembersListView(strategy: ExactAmountSplitStrategy(
            splitGroup: SplitGroup.stub,
            total: MonetaryAmount(currency: .eur, amount: 10.0))
        )
    }
}
