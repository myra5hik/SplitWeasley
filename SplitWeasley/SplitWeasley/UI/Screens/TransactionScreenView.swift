//
//  TransactionScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 16/11/22.
//

import SwiftUI

struct TransactionScreenView<VM: ITransactionScreenViewModel>: View {
    // View model
    @ObservedObject private var vm: VM
    // Constants
    private let buttonDiameter: CGFloat = 64
    private let horizontalInsets: CGFloat = 40
    // Etc
    private let numberFormatter: Formatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        nf.groupingSeparator = ""
        nf.zeroSymbol = ""
        return nf
    }()
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
        HStack {
            RoundButton(bodyFill: Color(UIColor.systemBackground)) {
                Image(systemName: "dollarsign")
                    .resizable()
                    .font(.system(size: 17, weight: .semibold))
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.5)
            }
            .frame(width: buttonDiameter, height: buttonDiameter)
            TextField(value: $vm.transactionAmount, formatter: numberFormatter, label: { Text("0.0") })
                .keyboardType(.decimalPad)
                .font(.largeTitle.weight(.semibold))
                .padding(.leading)
        }
    }
}

// MARK: - ViewModel

protocol ITransactionScreenViewModel: ObservableObject {
    var date: Date { get set }
    var transactionDescription: String { get set }
    var transactionAmount: Double { get set }
    var transactionCurrency: Currency { get set }
    var payee: String { get set }
    var splitWithin: String { get set }
}

final class TransactionScreenViewModel: ObservableObject {
    @Published var date = Date()
    @Published var transactionDescription = ""
    @Published var monetaryAmount = MonetaryAmount(currency: .usd, amount: 0.0)
}

extension TransactionScreenViewModel: ITransactionScreenViewModel {
    var transactionAmount: Double {
        get { NSDecimalNumber(decimal: monetaryAmount.amount).doubleValue }
        set { monetaryAmount.amount = Decimal(floatLiteral: newValue) }
    }

    var transactionCurrency: Currency {
        get { monetaryAmount.currency }
        set(newCurrency) { monetaryAmount = monetaryAmount.with(newCurrency) }
    }

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
