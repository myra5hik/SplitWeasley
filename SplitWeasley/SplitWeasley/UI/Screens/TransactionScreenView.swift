//
//  TransactionScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 16/11/22.
//

import SwiftUI

struct TransactionScreenView<VM: ITransactionScreenViewModel, R: IRouter>: View
where R.F.RD == AddTransactionModule.RoutingDestination {
    // View model
    @ObservedObject private var vm: VM
    // Router
    private let router: R
    // Constants
    private let buttonDiameter: CGFloat = 64
    private let horizontalInsets: CGFloat = 40
    // MARK: Init
    init(vm: VM = TransactionScreenViewModel(), router: R) {
        self.vm = vm
        self.router = router
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
                router.present(.splitStrategySelector)
            }
        )
    }

    var descriptionInputRowView: some View {
        let categoryButton = RoundButton(
            bodyFill: vm.transactionCategory.backgroundColor,
            action: {
                router.present(.categorySelector)
            }
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
    var date: Date { get set }
    var transactionCategory: TransactionCategory { get set }
    var transactionDescription: String { get set }
    var amount: MonetaryAmount { get set }
    var splitStrategy: any ISplitStrategy { get set }
    var payee: String { get }
    var splitWithin: String { get }
}

final class TransactionScreenViewModel: ObservableObject {
    // Data
    @Published var date = Date()
    @Published var transactionCategory: TransactionCategory = .undefined
    @Published var transactionDescription = ""
    @Published var amount = MonetaryAmount(currency: .eur) {
        didSet { splitStrategy.total = amount }
    }
    @Published var splitStrategy: any ISplitStrategy = EqualSharesSplitStrategy(
        splitGroup: SplitGroup.stub,
        total: MonetaryAmount(currency: .eur)
    )
}

extension TransactionScreenViewModel: ITransactionScreenViewModel {
    var payee: String { "you" }
    var splitWithin: String { splitStrategy.conciseHintDescription }
}

// MARK: - Previews

struct TransactionScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionScreenView(router: StubRouter<AddTransactionModule>())
    }
}
