//
//  PercentageSplitMembersListView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 01/12/22.
//

import SwiftUI

struct PercentageSplitMembersListView<S: IPercentageSplitStrategy, PPS: IProfilePictureService>: View {
    @ObservedObject private var strategy: S
    @FocusState private var focus: Person.ID?
    // Dependencies
    private let service: PPS

    init(strategy: S, profilePictureService: PPS) {
        self.strategy = strategy
        self.service = profilePictureService
    }

    var body: some View {
        List {
            Section {
                ForEach(strategy.splitGroup.members, id: \.id) { member in
                    ConfugurableListRowView(
                        heading: member.fullName,
                        subheading: strategy.amount(for: member.id)?.formatted() ?? "",
                        leadingAccessory: { ProfilePicture(service: service, personId: member.id) },
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
            .focused($focus, equals: memberId)
    }
}

struct PercentageSplitMembersListView_Previews: PreviewProvider {
    static var previews: some View {
        PercentageSplitMembersListView(
            strategy: PercentageSplitStrategy(
                splitGroup: SplitGroup.stub,
                total: MonetaryAmount(currency: .eur, amount: 10.0)
            ),
            profilePictureService: StubSyncProfilePictureService()
        )
    }
}
