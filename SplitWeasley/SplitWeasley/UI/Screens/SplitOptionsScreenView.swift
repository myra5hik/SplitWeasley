//
//  SplitOptionsScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 20/11/22.
//

import SwiftUI

struct SplitOptionsScreenView<
    ESSS: IEqualSharesSplitStrategy,
    EASS: IExactAmountSplitStrategy
>: View {
    // TODO: Store splitGroup in split strategy objects instead of views
    // Data
    private let splitGroup: SplitGroup
    private let total: MonetaryAmount
    // State
    @State private var pickerSelection: PickerSelection = .equalShares
    // Split parameters
    @StateObject private var equalSharesSplitStrategy: ESSS
    @StateObject private var exactAmountSplitStrategy: EASS
    // Actions
    private let onDismiss: (() -> Void)?
    private let onDone: ((any ISplitStrategy) -> Void)?

    init(
        splitGroup: SplitGroup,
        total: MonetaryAmount,
        equalSharesSplitStrategy: ESSS.Type = EqualSharesSplitStrategy.self,
        exactAmountSplitStrategy: EASS.Type = ExactAmountSplitStrategy.self,
        initialState: (any ISplitStrategy)? = nil,
        onDismiss: (() -> Void)? = nil,
        onDone: ((any ISplitStrategy) -> Void)? = nil
    ) {
        self.splitGroup = splitGroup
        self.total = total
        self._equalSharesSplitStrategy = StateObject(
            wrappedValue: equalSharesSplitStrategy.init(splitGroup: splitGroup, total: total)
        )
        self._exactAmountSplitStrategy = StateObject(
            wrappedValue: exactAmountSplitStrategy.init(splitGroup: splitGroup, total: total)
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
                .id(pickerSelection)
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
            case .percent: EmptyView()
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
                action: { equalSharesSplitStrategy.isIncluded[member.id]?.toggle() }
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
                            // Requires hussle as one can't subsctipt a Binding<Dictionary<...>>
                            let defaultValue = MonetaryAmount(
                                currency: exactAmountSplitStrategy.total.currency
                            )
                            let amountBinding = Binding(
                                get: { exactAmountSplitStrategy.inputAmount[member.id] ?? defaultValue },
                                set: { exactAmountSplitStrategy.inputAmount[member.id] = $0 }
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
        case .percent: return nil
        case .unequalShares: return nil
        case .plusMinus: return nil
        }
    }

    mutating
    func restoreState(_ state: any ISplitStrategy) {
        switch state {
        case let state as ESSS:
            _equalSharesSplitStrategy = StateObject(wrappedValue: state)
            _pickerSelection = .init(initialValue: .equalShares)
        case let state as EASS:
            _exactAmountSplitStrategy = StateObject(wrappedValue: state)
            _pickerSelection = .init(initialValue: .exactAmount)
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
