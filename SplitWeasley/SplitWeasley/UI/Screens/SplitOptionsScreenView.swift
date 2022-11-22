//
//  SplitOptionsScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 20/11/22.
//

import SwiftUI

struct SplitOptionsScreenView<ESSS: IEqualSharesSplitStrategy>: View {
    // Data
    private let splitGroup: SplitGroup
    // State
    @State private var pickerSelection: Int = 0
    // Split parameters
    @StateObject private var equalSharesSplitStrategy: ESSS

    init(
        splitGroup: SplitGroup,
        total: MonetaryAmount,
        equalSharesSplitStrategy: ESSS.Type = EqualSharesSplitStrategy.self
    ) {
        self.splitGroup = splitGroup
        self._equalSharesSplitStrategy = StateObject(
            wrappedValue: equalSharesSplitStrategy.init(splitGroup: splitGroup, total: total)
        )
    }

    var body: some View {
        VStack {
            VStack(spacing: 8) {
                splitStrategySegmentedControlView
                hintPlateView
            }
            .padding()
            splitGroupMembersListView
        }
    }
}

// MARK: - Components

private extension SplitOptionsScreenView {
    var splitStrategySegmentedControlView: some View {
        Picker(selection: $pickerSelection) {
            Image(systemName: "equal").tag(0)
            Text("1.23").tag(1)
            Image(systemName: "percent").tag(2)
            Image(systemName: "chart.pie.fill").tag(3)
            Image(systemName: "plus.forwardslash.minus").tag(4)
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
    }

    var hintPlateView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .foregroundColor(Color(uiColor: .tertiarySystemFill))
            VStack {
                Text(equalSharesSplitStrategy.hintHeader).font(.headline)
                Text(equalSharesSplitStrategy.hintDescription).font(.subheadline)
            }
        }
        .frame(height: 60)
    }

    var splitGroupMembersListView: some View {
        List(splitGroup.members, id: \.id) { member in
            ConfugurableListRowView(
                heading: member.fullName,
                subheading: {
                    if let amount = equalSharesSplitStrategy.amount(for: member.id) { return amount.formatted() }
                    return "not involved"
                }(),
                leadingAccessory: { Circle().foregroundColor(.blue) },
                trailingAccessory: {
                    let isIncluded = equalSharesSplitStrategy.isIncluded[member.id] ?? false
                    if isIncluded { Image(systemName: "checkmark") }
                },
                action: { equalSharesSplitStrategy.isIncluded[member.id]?.toggle() }
            )
        }
        .listStyle(.plain)
    }
}

// MARK: - Previews

struct SplitOptionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplitOptionsScreenView(
            splitGroup: SplitGroup(
                id: UUID(),
                members: [
                    Person(id: UUID(), firstName: "Alexander", lastName: nil),
                    Person(id: UUID(), firstName: "Alena", lastName: nil),
                    Person(id: UUID(), firstName: "Ilia", lastName: nil),
                    Person(id: UUID(), firstName: "Oleg", lastName: nil)
                ]
            ),
            total: MonetaryAmount(currency: .jpy, amount: 100003.0)
        )
    }
}
