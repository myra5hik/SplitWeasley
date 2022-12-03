//
//  PlusMinusSplitMembersListView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 02/12/22.
//

import SwiftUI

struct PlusMinusSplitMembersListView<S: IPlusMinusSplitStrategy>: View {
    @ObservedObject private var strategy: S
    private var currency: Currency { strategy.total.currency }

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
                        trailingAccessory: { makeTrailingView(memberId: member.id) },
                        action: { strategy.toggleInvolvement(for: member.id) }
                    )
                    .frame(height: 38)
//                    .animation(.linear(duration: 0.1), value: strategy.adjustments[member.id] == nil)
                }
            }
        }
        .listStyle(.plain)
    }

    private func makeSubheading(memberId: Person.ID) -> String {
        guard let amount = strategy.amount(for: memberId) else { return "not involved" }
        // Total amount
        var res = "\(amount.formatted())"
        // Additional information in case there is an adjustment
        if let adjustment = strategy.adjustments[memberId], adjustment.amount != 0.0 {
            let applyingFormatting: (Decimal) -> (String) = {
                $0.formatted(.number.precision(.fractionLength(0...currency.roundingScale)))
            }
            let commonShare = applyingFormatting(strategy.commonSharePerPerson.amount)
            let adjustment = applyingFormatting(adjustment.amount)
            res += " (\(commonShare) + \(adjustment))"
        }
        return res
    }

    private func makeTrailingView(memberId: Person.ID) -> some View {
        HStack {
            if strategy.amount(for: memberId) != nil {
                makeInputView(memberId: memberId)
                Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
            }
        }
        .frame(minWidth: 50, maxWidth: .infinity)
        .fixedSize()
    }

    private func makeInputView(memberId: Person.ID) -> some View {
        let binding = Binding(
            get: { strategy.adjustments[memberId]?.amount ?? 0.0 },
            set: { strategy.set(MonetaryAmount(currency: currency, amount: $0), for: memberId) }
        )
        return NumericInputView(
            binding,
            roundingScale: currency.roundingScale,
            placeholder: "\(MonetaryAmount(currency: currency).formatted())"
        )
        .multilineTextAlignment(.trailing)
    }
}

// MARK: - Previews

struct PlusMinusSplitMembersListView_Previews: PreviewProvider {
    static var previews: some View {
        PlusMinusSplitMembersListView(strategy: PlusMinusSplitStrategy(
            splitGroup: SplitGroup.stub,
            total: MonetaryAmount(currency: .eur, amount: 100.0))
        )
    }
}
