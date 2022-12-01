//
//  UnequalSharesSplitMembersListView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 01/12/22.
//

import SwiftUI

struct UnequalSharesSplitMembersListView<S: IUnequalSharesSplitStrategy>: View {
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
                        subheading: strategy.amount(for: member.id)?.formatted() ?? "not involved",
                        leadingAccessory: { Circle().foregroundColor(.blue) },
                        trailingAccessory: { makeInputView(memberId: member.id) }
                    )
                    .frame(height: 38)
                }
            }
        }
        .listStyle(.plain)
    }

    private func makeInputView(memberId: Person.ID) -> some View {
        let binding = Binding(
            get: { Int(strategy.amountOfShares[memberId] ?? 0) },
            set: { strategy.set($0, for: memberId) }
        )
        return HStack {
            Text("\(binding.wrappedValue)").bold()
            Stepper("Amount of shares", value: binding)
                .labelsHidden()
        }
    }
}

// MARK: - Previews

struct UnequalSharesSplitMembersListView_Previews: PreviewProvider {
    static var previews: some View {
        UnequalSharesSplitMembersListView(strategy: UnequalSharesSplitStrategy(
            splitGroup: SplitGroup.stub,
            total: MonetaryAmount(currency: .eur, amount: 100.0))
        )
    }
}
