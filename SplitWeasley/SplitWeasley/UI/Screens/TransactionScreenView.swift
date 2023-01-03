//
//  TransactionScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 16/11/22.
//

import SwiftUI
import Combine

struct TransactionScreenView<VM: ITransactionScreenViewModel>: View {
    // View model
    @ObservedObject private var vm: VM
    // Constants
    private let buttonDiameter: CGFloat = 64
    private let horizontalInsets: CGFloat = 40
    // MARK: Init
    init(vm: VM = TransactionScreenViewModel()) {
        self.vm = vm
    }
    // MARK: Body
    var body: some View {
        VStack {
            VStack {
                Spacer()
                datePicker
                Spacer()
                mainInputViews
                Spacer()
                paidAndSplitBar
                Spacer()
            }
            .frame(height: 400)
            Spacer()
        }
        .navigationTitle("Trip to Turkey")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save", action: { }).fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $vm.isPresentingSplitOptionsView) {
            vm.splitOptionsScreenView
        }
        .sheet(isPresented: $vm.isPresentingCategorySelectionView) {
            vm.categorySelectionScreenView
        }
    }
}

// MARK: - Components

private extension TransactionScreenView {
    var datePicker: some View {
        DatePicker(
            selection: $vm.date,
            displayedComponents: [.date, .hourAndMinute],
            label: { EmptyView() }
        )
        .labelsHidden()
        .datePickerStyle(.compact)
    }

    var mainInputViews: some View {
        return VStack(spacing: 16) {
            descriptionInputRowView
            amountInputRowView
        }
        .padding(.horizontal, horizontalInsets)
    }

    var paidAndSplitBar: some View {
        PaidAndSplitBarView(
            payeeLabel: vm.payee,
            splitLabel: vm.splitWithin,
            payeeAction: nil,
            splitAction: { [weak vm] in
                guard (vm?.amount.amount ?? 0) > 0 else { return }
                vm?.isPresentingSplitOptionsView = true
            }
        )
    }

    var descriptionInputRowView: some View {
        let categoryButton = RoundButton(
            bodyFill: vm.transactionCategory.backgroundColor,
            action: { vm.isPresentingCategorySelectionView = true }
        ) {
            vm.transactionCategory.icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(vm.transactionCategory.foregroundColor)
                .scaleEffect(0.5)
        }
        .frame(width: buttonDiameter, height: buttonDiameter)

        let descriptionInputField = TextField("Description", text: $vm.transactionDescription, axis: .vertical)
            .font(.title2)
            .lineLimit(2)
            .keyboardType(.asciiCapable)
            .padding(.leading)

        return HStack {
            categoryButton
            descriptionInputField
        }
    }

    var amountInputRowView: some View {
        let currencyButton = RoundButton(bodyFill: .white) {
            Image(systemName: vm.amount.currency.iconString)
                .font(.title)
                .fontWeight(.medium)
        }
        .frame(width: buttonDiameter, height: buttonDiameter)
        .foregroundColor(.black)

        let currencyOptions = ForEach(Currency.allCases) { currency in
            Button(
                action: { [weak vm] in
                    guard let vm = vm else { return }
                    vm.amount = vm.amount.with(currency: currency)
                },
                label: { Label(currency.name, systemImage: currency.iconString) }
            )
        }

        let amountInput = NumericInputView(
            Binding(
                get: { vm.amount.amount },
                set: { vm.amount = vm.amount.with(amount: $0) }
            ),
            roundingScale: vm.amount.currency.roundingScale,
            placeholder: "0.0 \(vm.amount.currency.iso4217code)"
        )
        .keyboardType(.decimalPad)
        .font(.largeTitle.weight(.semibold))
        .padding(.leading)

        return HStack {
            Menu(content: { currencyOptions }, label: { currencyButton })
            amountInput
        }
    }
}

// MARK: - ViewModel

protocol ITransactionScreenViewModel: ObservableObject {
    associatedtype CategorySelectionViewType: View
    associatedtype SplitOptionsScreenViewType: View

    var date: Date { get set }
    var transactionCategory: TransactionCategory { get set }
    var transactionDescription: String { get set }
    var amount: MonetaryAmount { get set }
    // TODO: Rework as get-only
    var payee: String { get }
    var splitWithin: String { get }
    // Routing
    // TODO: Factor Routing out to a separate class
    var categorySelectionScreenView: CategorySelectionViewType { get }
    var splitOptionsScreenView: SplitOptionsScreenViewType { get }
    var isPresentingCategorySelectionView: Bool { get set }
    var isPresentingSplitOptionsView: Bool { get set }
}

final class TransactionScreenViewModel: ObservableObject {
    // Data
    @Published var date = Date()
    @Published var transactionCategory: TransactionCategory = .undefined
    @Published var transactionDescription = ""
    @Published var amount = MonetaryAmount(currency: .eur) {
        didSet { splitStrategy.total = amount }
    }
    private var splitStrategy: any ISplitStrategy = EqualSharesSplitStrategy(
        splitGroup: SplitGroup.stub,
        total: MonetaryAmount(currency: .eur)
    ) {
        willSet { objectWillChange.send() }
    }
    // Routing
    @Published var isPresentingSplitOptionsView = false
    @Published var isPresentingCategorySelectionView = false
}

extension TransactionScreenViewModel: ITransactionScreenViewModel {
    var payee: String { "you" }

    var splitWithin: String { splitStrategy.conciseHintDescription }

    var splitOptionsScreenView: some View {
        SplitOptionsScreenView(
            splitGroup: splitStrategy.splitGroup,
            total: amount,
            initialState: splitStrategy,
            onDismiss: { [weak self] in self?.isPresentingSplitOptionsView = false },
            onDone: { [weak self] updatedStrategy in
                self?.splitStrategy = updatedStrategy
                self?.isPresentingSplitOptionsView = false
            }
        )
    }

    var categorySelectionScreenView: some View {
        let cancelButton = Button("Cancel", role: .cancel) { [weak self] in
            self?.isPresentingCategorySelectionView = false
        }

        return NavigationView {
            TransactionCategorySelectionList { [weak self] (category) in
                self?.transactionCategory = category
                self?.isPresentingCategorySelectionView = false
            }
            .navigationTitle("Select category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { cancelButton }
        }
    }
}

// MARK: - Previews

struct TransactionScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionScreenView()
    }
}
