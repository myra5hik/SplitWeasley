//
//  TransactionScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 16/11/22.
//

import SwiftUI

struct TransactionScreenView: View {
    // State
    @State private var date = Date()
    @State private var description = ""
    @State private var amount: Double = 0.0
    // Etc
    private let numberFormatter: Formatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        nf.zeroSymbol = ""
        return nf
    }()

    var body: some View {
        VStack {
            Spacer()
            datePicker
            Spacer()
            mainInputViews
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Components

private extension TransactionScreenView {
    var datePicker: some View {
        DatePicker(
            selection: $date,
            displayedComponents: [.date, .hourAndMinute],
            label: { EmptyView() }
        )
        .labelsHidden()
        .datePickerStyle(.compact)
    }

    var mainInputViews: some View {
        let buttonDiameter: CGFloat = 80

        return VStack {
            HStack {
                RoundButton(bodyFill: Color(UIColor.systemPurple)) {
                    Image(systemName: "airplane")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .scaleEffect(0.5)
                }
                .frame(width: buttonDiameter, height: buttonDiameter)
                TextField("Description", text: $description, axis: .vertical)
                    .font(.title2)
                    .lineLimit(2)
                    .keyboardType(.asciiCapable)
                    .padding(.leading)
            }
            HStack {
                RoundButton(bodyFill: Color(UIColor.systemBackground)) {
                    Image(systemName: "dollarsign")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(0.5)
                }
                .frame(width: buttonDiameter, height: buttonDiameter)
                TextField(value: $amount, formatter: numberFormatter, label: { Text("0.0") })
                    .keyboardType(.decimalPad)
                    .font(.largeTitle)
                    .padding(.leading)
            }
        }
        .padding(.horizontal, 40)
    }
}

struct TransactionScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionScreenView()
    }
}
