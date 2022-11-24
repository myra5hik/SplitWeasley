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
                PaidAndSplitBarView(
                    payeeLabel: $vm.payee,
                    splitLabel: $vm.splitWithin,
                    payeeAction: nil,
                    splitAction: nil
                )
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

    var descriptionInputRowView: some View {
        HStack {
            RoundButton(bodyFill: Color(UIColor.systemPurple.withAlphaComponent(0.75))) {
                Image(systemName: "airplane")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .scaleEffect(0.5)
            }
            .frame(width: buttonDiameter, height: buttonDiameter)
            TextField("Description", text: $vm.transactionDescription, axis: .vertical)
                .font(.title2)
                .lineLimit(2)
                .keyboardType(.asciiCapable)
                .padding(.leading)
        }
    }

    var amountInputRowView: some View {
        let currencyButton = RoundButton(bodyFill: Color(UIColor.systemBackground)) {
            Image(systemName: vm.inputProxy.monetaryAmount.currency.iconString)
                .font(.title)
                .fontWeight(.medium)
        }
        .frame(width: buttonDiameter, height: buttonDiameter)
        .foregroundColor(Color(uiColor: UIColor.label))

        let currencyOptions = ForEach(Currency.allCases) { currency in
            Button(
                action: { [weak vm] in vm?.inputProxy.currency = currency },
                label: { Label(currency.name, systemImage: currency.iconString) }
            )
        }

        let amountInput = MonetaryAmountInputView(inputProxy: vm.inputProxy)
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
    var transactionDescription: String { get set }
    var inputProxy: MonetaryAmountInputProxy { get }
    var currency: Currency { get set }
    var payee: String { get set }
    var splitWithin: String { get set }
}

final class TransactionScreenViewModel: ObservableObject {
    @Published var date = Date()
    @Published var transactionDescription = ""
    @Published var currency: Currency
    let inputProxy = MonetaryAmountInputProxy(MonetaryAmount(currency: .eur))
    private var bag = Set<AnyCancellable>()

    init() {
        self.currency = inputProxy.currency
        subscribeCurrencyToProxy()
    }

    private func subscribeCurrencyToProxy() {
        let storable = inputProxy.$monetaryAmount.sink { [weak self] in
            self?.currency = $0.currency
        }
        storable.store(in: &bag)
    }
}

extension TransactionScreenViewModel: ITransactionScreenViewModel {
    var payee: String {
        get { "you" }
        set { }
    }

    var splitWithin: String {
        get { "equally" }
        set { }
    }
}

// MARK: - Previews

struct TransactionScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionScreenView()
    }
}
