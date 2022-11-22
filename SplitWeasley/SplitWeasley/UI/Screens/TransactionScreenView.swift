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
            Image(systemName: vm.transactionCurrency.iconString)
                .font(.title)
                .fontWeight(.medium)
        }
        .frame(width: buttonDiameter, height: buttonDiameter)
        .foregroundColor(Color(uiColor: UIColor.label))

        let currencyOptions = ForEach(Currency.allCases) { currency in
            Button(
                action: { [weak vm] in vm?.transactionCurrency = currency },
                label: { Label(currency.name, systemImage: currency.iconString) }
            )
        }

        let amountInput = TextField(text: $vm.transactionAmount) {
            Text("0.0 \(vm.transactionCurrency.iso4217code)")
        }
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
    var transactionAmount: String { get set }
    var transactionCurrency: Currency { get set }
    var payee: String { get set }
    var splitWithin: String { get set }
}

final class TransactionScreenViewModel: ObservableObject {
    // Inputs
    @Published var date = Date()
    @Published var transactionDescription = ""
    @Published var monetaryAmount = MonetaryAmount(currency: .eur, amount: 0.0)
    private let separatorSymbol = "\(Locale.current.decimalSeparator ?? "")"
    // Logics
    private var shouldAddTrailingSeparator = false
    private var amountOfTrailingZeros = 0
}

extension TransactionScreenViewModel: ITransactionScreenViewModel {
    var transactionAmount: String {
        get {
            let amount = monetaryAmount.amount
            if amount == 0.0 { return "" }
            var res = "\(amount)"
            // Adds a trailing separator if flag set to true
            if shouldAddTrailingSeparator { res += separatorSymbol }
            // Adds a separator if fractional part consists of only trailing zeros
            if (amountOfTrailingZeros > 0 && amount.rounded(scale: 0) == amount) { res += separatorSymbol }
            // Adds the required amount of trailing zeros
            res += Array(repeating: "0", count: amountOfTrailingZeros)
            return res
        }

        set {
            // Fallback: sets the amount to the previous value to trigger publisher
            let fallback = { [weak self] in
                guard let self = self else { return }
                self.monetaryAmount = self.monetaryAmount
            }
            // For an empty string, sets the value to 0.0
            if newValue == "" { monetaryAmount = monetaryAmount.with(amount: 0.0) }
            // Checks the input is a valid numeric input
            guard let properNumber = Double(newValue) else { fallback(); return }
            // Logic around fractional values of the decimal
            let splits = newValue.split(separator: separatorSymbol, omittingEmptySubsequences: false)
            if splits.count == 2, let last = newValue.last {
                // Forbids inputting more fractional digits than allowed for the currency
                guard splits[1].count <= monetaryAmount.currency.roundingScale else { fallback(); return }
                // Sets trailing separator flag, so that the getter keeps it
                shouldAddTrailingSeparator = (String(last) == separatorSymbol) ? true : false
                // Sets the amount of trailing zeros, so that the getter keeps them
                amountOfTrailingZeros = String(splits[1]).amountOfTrailingZeros()
            } else {
                shouldAddTrailingSeparator = false
                amountOfTrailingZeros = 0
            }

            monetaryAmount = monetaryAmount.with(amount: Decimal(properNumber))
        }
    }

    var transactionCurrency: Currency {
        get { monetaryAmount.currency }
        set(newCurrency) { monetaryAmount = monetaryAmount.with(currency: newCurrency) }
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

// MARK: - Local helper

private extension String {
    func amountOfTrailingZeros() -> Int {
        var res = 0
        for c in self.reversed() {
            if c != "0" { break } else { res += 1 }
        }
        return res
    }
}

// MARK: - Previews

struct TransactionScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionScreenView()
    }
}
