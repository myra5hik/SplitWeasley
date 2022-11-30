//
//  SplitOptionsScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 20/11/22.
//

import SwiftUI

struct SplitOptionsScreenView<
    ESSS: IEqualSharesSplitStrategy,
    EASS: IExactAmountSplitStrategy,
    PSS: IPercentageSplitStrategy
>: View {
    // State
    @State private var pickerSelection: PickerSelection = .percent
    // Split parameters
    @StateObject private var equalSharesSplitStrategy: ESSS
    @StateObject private var exactAmountSplitStrategy: EASS
    @StateObject private var percentageSplitStrategy: PSS
    // Actions
    private let onDismiss: (() -> Void)?
    private let onDone: ((any ISplitStrategy) -> Void)?

    init(
        splitGroup: SplitGroup,
        total: MonetaryAmount,
        equalSharesSplitStrategy: ESSS.Type = EqualSharesSplitStrategy.self,
        exactAmountSplitStrategy: EASS.Type = ExactAmountSplitStrategy.self,
        percentageSplitStrategy: PSS.Type = PercentageSplitStrategy.self,
        initialState: (any ISplitStrategy)? = nil,
        onDismiss: (() -> Void)? = nil,
        onDone: ((any ISplitStrategy) -> Void)? = nil
    ) {
        self._equalSharesSplitStrategy = StateObject(
            wrappedValue: equalSharesSplitStrategy.init(splitGroup: splitGroup, total: total)
        )
        self._exactAmountSplitStrategy = StateObject(
            wrappedValue: exactAmountSplitStrategy.init(splitGroup: splitGroup, total: total)
        )
        self._percentageSplitStrategy = StateObject(
            wrappedValue: percentageSplitStrategy.init(splitGroup: splitGroup, total: total)
        )
        // Actions
        self.onDismiss = onDismiss
        self.onDone = onDone
        // State restoration
        if let initialState = initialState { restoreState(initialState) }
    }

    var body: some View {
        NavigationStack {
            applyingNavigationModifiers {
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
    }

    private func applyingNavigationModifiers(_ content: () -> (some View)) -> some View {
        content()
            .navigationTitle("Split Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: { onDismiss?() })
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done", action: {
                        onDone?(strategyForPickerSelection() ?? equalSharesSplitStrategy)
                    })
                    .disabled(!(strategyForPickerSelection()?.isLogicallyConsistent ?? false))
                    .bold()
                }
            }
    }
}

// MARK: - Components

private extension SplitOptionsScreenView {
    var splitStrategySegmentedControlView: some View {
        Picker(selection: $pickerSelection) {
            Image(systemName: "equal").tag(PickerSelection.equalShares)
            Text("1.23").tag(PickerSelection.exactAmount)
            Image(systemName: "percent").tag(PickerSelection.percent)
            Image(systemName: "chart.pie.fill").tag(PickerSelection.unequalShares)
            Image(systemName: "plus.forwardslash.minus").tag(PickerSelection.plusMinus)
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
                if let strategy = strategyForPickerSelection() {
                    Text(strategy.hintHeader).font(.headline)
                    Text(strategy.hintDescription).font(.subheadline)
                } else {
                    EmptyView()
                }
            }
        }
        .frame(height: 60)
    }

    var splitGroupMembersListView: some View {
        VStack {
            switch pickerSelection {
            case .equalShares: equalSharesSplitMembersListView
            case .exactAmount: exactAmountSplitMembersListView
            case .percent: percentageSplitMembersListView
            case .unequalShares: EmptyView()
            case .plusMinus: EmptyView()
            }
            Spacer()
        }
    }

    var equalSharesSplitMembersListView: some View {
        List(equalSharesSplitStrategy.splitGroup.members, id: \.id) { member in
            ConfugurableListRowView(
                heading: member.fullName,
                subheading: {
                    if let amount = equalSharesSplitStrategy.amount(for: member.id) {
                        return amount.formatted()
                    }
                    return "not involved"
                }(),
                leadingAccessory: { Circle().foregroundColor(.blue) },
                trailingAccessory: {
                    let isIncluded = equalSharesSplitStrategy.isIncluded[member.id] ?? false
                    if isIncluded { Image(systemName: "checkmark") }
                },
                action: {
                    let isIncluded = equalSharesSplitStrategy.isIncluded[member.id] ?? false
                    equalSharesSplitStrategy.set(!isIncluded, for: member.id)
                }
            )
        }
        .listStyle(.plain)
    }

    var exactAmountSplitMembersListView: some View {
        List {
            Section {
                ForEach(exactAmountSplitStrategy.splitGroup.members, id: \.id) { member in
                    ConfugurableListRowView(
                        heading: member.fullName,
                        leadingAccessory: { Circle().foregroundColor(.blue) },
                        trailingAccessory: {
                            let defaultValue = MonetaryAmount(
                                currency: exactAmountSplitStrategy.total.currency
                            )
                            let amountBinding = Binding(
                                get: { exactAmountSplitStrategy.amount(for: member.id) ?? defaultValue },
                                set: { exactAmountSplitStrategy.set($0, for: member.id) }
                            )
                            // Return view
                            MonetaryAmountInputView(monetaryAmount: amountBinding)
                                .multilineTextAlignment(.trailing)
                        }
                    )
                }
            }
            ConfugurableListRowView(
                heading: "Left to Distribute:",
                leadingAccessory: { Rectangle().foregroundColor(Color(uiColor: .clear)) },
                trailingAccessory: {
                    Text(exactAmountSplitStrategy.remainingAmount.formatted())
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            )
        }
        .listStyle(.plain)
    }

    var percentageSplitMembersListView: some View {
        List {
            Section {
                ForEach(percentageSplitStrategy.splitGroup.members, id: \.id) { member in
                    ConfugurableListRowView(
                        heading: member.fullName,
                        subheading: {
                            if let amount = percentageSplitStrategy.amount(for: member.id) {
                                return amount.formatted()
                            } else {
                                return ""
                            }
                        }(),
                        leadingAccessory: { Circle().foregroundColor(.blue) },
                        trailingAccessory: {
                            let binding = Binding(
                                get: { percentageSplitStrategy.inputAmount[member.id] ?? 0.0 },
                                set: { percentageSplitStrategy.set($0, for: member.id) }
                            )
                            TextField("0.0", value: binding, format: .percent)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                        }
                    )
                }
            }
            ConfugurableListRowView(
                heading: "Left to Distribute:",
                leadingAccessory: { Rectangle().foregroundColor(Color(uiColor: .clear)) },
                trailingAccessory: {
                    Text(percentageSplitStrategy.remainingAmount.formatted(.percent))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            )
        }
        .listStyle(.plain)
    }
}

// MARK: - PickerSelection

private extension SplitOptionsScreenView {
    enum PickerSelection {
        case equalShares, exactAmount, percent, unequalShares, plusMinus
    }

    func strategyForPickerSelection() -> (any ISplitStrategy)? {
        switch pickerSelection {
        case .equalShares: return equalSharesSplitStrategy
        case .exactAmount: return exactAmountSplitStrategy
        case .percent: return percentageSplitStrategy
        case .unequalShares: return nil
        case .plusMinus: return nil
        }
    }

    mutating
    func restoreState(_ state: any ISplitStrategy) {
        switch state {
        case let state as ESSS: // Equal shares
            _equalSharesSplitStrategy = StateObject(wrappedValue: state)
            _pickerSelection = .init(initialValue: .equalShares)
        case let state as EASS: // Exact amounts
            _exactAmountSplitStrategy = StateObject(wrappedValue: state)
            _pickerSelection = .init(initialValue: .exactAmount)
        case let state as PSS: // Percentage split
            _percentageSplitStrategy = StateObject(wrappedValue: state)
            _pickerSelection = .init(initialValue: .percent)
        default:
            assertionFailure()
        }
    }
}

// MARK: - Previews

struct SplitOptionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplitOptionsScreenView(
            splitGroup: SplitGroup.stub,
            total: MonetaryAmount(currency: .eur, amount: 100.0)
        )
    }
}
