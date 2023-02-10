//
//  PlusMinusSplitMembersListView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 02/12/22.
//

import SwiftUI

struct PlusMinusSplitMembersListView<S: IPlusMinusSplitStrategy, PPS: IProfilePictureService>: View {
    @ObservedObject private var strategy: S
    @FocusState var focusCell: Person.ID?
    private var currency: Currency { strategy.total.currency }
    // Dependencies
    private let service: PPS

    init(strategy: S, profilePictureService: PPS) {
        self.strategy = strategy
        self.service = profilePictureService
    }

    var body: some View {
        List {
            let membersEnumerated = Array(strategy.splitGroup.members.enumerated())
            ForEach(membersEnumerated, id: \.element.id) { (i, member) in
                ConfugurableListRowView(
                    heading: member.fullName,
                    subheading: makeSubheading(memberId: member.id),
                    leadingAccessory: { ProfilePicture(service: service, personId: member.id) },
                    trailingAccessory: { makeTrailingView(memberId: member.id, rowNum: i) },
                    action: { handleCellTapped(memberId: member.id) }
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    makeSwipeActionToggleInvolvementButton(memberId: member.id)
                }
                .frame(height: 38)
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

    @ViewBuilder
    private func makeTrailingView(memberId: Person.ID, rowNum: Int) -> some View {
        if strategy.amount(for: memberId) != nil {
            HStack {
                makeAmountInputView(id: memberId)
                makeCheckboxView(memberId: memberId)
            }
            // Following modifiers prioritise layout of input views over other labels
            .frame(minWidth: 50, maxWidth: .infinity)
            .fixedSize()
        } else {
            EmptyView()
        }
    }

    private func makeAmountInputView(id: Person.ID) -> some View {
        let binding = Binding(
            get: { [weak strategy] in strategy?.adjustments[id]?.amount ?? 0.0 },
            set: { [weak strategy] in strategy?.set(MonetaryAmount(currency: currency, amount: $0), for: id) }
        )
        return NumericInputView(
            binding,
            roundingScale: currency.roundingScale,
            placeholder: "\(MonetaryAmount(currency: currency).formatted())"
        )
        .multilineTextAlignment(.trailing)
        .focused($focusCell, equals: id)
    }

    private func makeCheckboxView(memberId: Person.ID) -> some View {
        Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
            .onTapGesture { strategy.toggleInvolvement(for: memberId) }
    }

    private func makeSwipeActionToggleInvolvementButton(memberId: Person.ID) -> some View {
        let isInvolved = strategy.adjustments[memberId] != nil
        return Button(action: {
            strategy.toggleInvolvement(for: memberId)
        }, label: {
            if isInvolved {
                Label("Exclude", systemImage: "person.fill.xmark")
            } else {
                Label("Include", systemImage: "person.fill.checkmark")
            }
        })
        .tint(isInvolved ? Color(uiColor: .systemOrange) : Color(uiColor: .systemTeal))
    }

    private func handleCellTapped(memberId: Person.ID) {
        if strategy.adjustments[memberId] == nil {
            // User is not involved and has no input view visible -> first toggle involvement
            strategy.toggleInvolvement(for: memberId)
        }
        focusCell = memberId
    }
}

// MARK: - Previews

struct PlusMinusSplitMembersListView_Previews: PreviewProvider {
    static var previews: some View {
        PlusMinusSplitMembersListView(
            strategy: PlusMinusSplitStrategy(
                splitGroup: SplitGroup.stub,
                total: MonetaryAmount(currency: .eur, amount: 100.0)
            ),
            profilePictureService: StubSyncProfilePictureService()
        )
    }
}
