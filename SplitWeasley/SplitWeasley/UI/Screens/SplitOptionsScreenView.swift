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
    PSS: IPercentageSplitStrategy,
    USSS: IUnequalSharesSplitStrategy,
    PMSS: IPlusMinusSplitStrategy
>: View {
    // State
    @State private var pickerSelection: PickerSelection = .equalShares
    // Split parameters
    @StateObject private var equalSharesSplitStrategy: ESSS
    @StateObject private var exactAmountSplitStrategy: EASS
    @StateObject private var percentageSplitStrategy: PSS
    @StateObject private var unequalSharesSplitStrategy: USSS
    @StateObject private var plusMinusSplitStrategy: PMSS
    // Actions
    private let onDismiss: (() -> Void)?
    private let onDone: ((any ISplitStrategy) -> Void)?

    init(
        splitGroup: SplitGroup,
        total: MonetaryAmount,
        equalSharesSplitStrategy: ESSS.Type = EqualSharesSplitStrategy.self,
        exactAmountSplitStrategy: EASS.Type = ExactAmountSplitStrategy.self,
        percentageSplitStrategy: PSS.Type = PercentageSplitStrategy.self,
        unequalSharesSplitStrategy: USSS.Type = UnequalSharesSplitStrategy.self,
        plusMinusSplitStrategy: PMSS.Type = PlusMinusSplitStrategy.self,
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
        self._unequalSharesSplitStrategy = StateObject(
            wrappedValue: unequalSharesSplitStrategy.init(splitGroup: splitGroup, total: total)
        )
        self._plusMinusSplitStrategy = StateObject(
            wrappedValue: plusMinusSplitStrategy.init(splitGroup: splitGroup, total: total)
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
            case .equalShares: EqualSharesSplitMembersListView(strategy: equalSharesSplitStrategy)
            case .exactAmount: ExactAmountSplitMembersListView(strategy: exactAmountSplitStrategy)
            case .percent: PercentageSplitMembersListView(strategy: percentageSplitStrategy)
            case .unequalShares: UnequalSharesSplitMembersListView(strategy: unequalSharesSplitStrategy)
            case .plusMinus: PlusMinusSplitMembersListView(strategy: plusMinusSplitStrategy)
            }
            Spacer()
        }
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
        case .unequalShares: return unequalSharesSplitStrategy
        case .plusMinus: return plusMinusSplitStrategy
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
        case let state as USSS: // Unequal shares split
            _unequalSharesSplitStrategy = StateObject(wrappedValue: state)
            _pickerSelection = .init(initialValue: .unequalShares)
        case let state as PMSS: // Plus-minus adjustment split
            _plusMinusSplitStrategy = StateObject(wrappedValue: state)
            _pickerSelection = .init(initialValue: .plusMinus)
        default:
            assertionFailure("Unrecognized split strategy state")
        }
    }
}

// MARK: - Previews

struct SplitOptionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplitOptionsScreenView(
            splitGroup: SplitGroup.stub,
            total: MonetaryAmount(currency: .eur, amount: 10.0)
        )
    }
}
