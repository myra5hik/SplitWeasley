//
//  GroupSummaryOverlayView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/01/23.
//

import SwiftUI

struct GroupSummaryOverlayView: View {
    private let balances: [MonetaryAmount]
    private let onTapOfInfo: (() -> Void)?

    init(balances: [MonetaryAmount], onTapOfInfo: (() -> Void)? = nil) {
        self.balances = balances.filter({ $0.amount != 0.0 })
        self.onTapOfInfo = onTapOfInfo
    }

    var body: some View {
        HStack {
            headingText
            Spacer()
            balanceTexts
            infoButton
        }
        .padding(.horizontal)
        .background(content: { background })
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 6)
            .foregroundColor(Color(uiColor: .tertiarySystemFill))
    }

    private var headingText: some View {
        Text("Your balance:")
            .font(.headline)
            .fontWeight(.light)
    }

    @ViewBuilder
    private var balanceTexts: some View {
        if !balances.isEmpty {
            nonSettledBalance
        } else {
            settledBalance
        }
    }

    private var nonSettledBalance: some View {
        VStack(alignment: .leading) {
            ForEach(balances, id: \.hashValue) { amount in
                let isNegative = amount.amount < 0.0
                /// Adds spacing for non-negative numbers so that the minus sign is handing and the text block is aligned by currencies
                let spacing = "\(Unicode.Scalar(0x2000)!)"
                let string = (isNegative ? "" : spacing) + amount.formatted()

                Text(string)
                    .foregroundColor(isNegative ? Color(uiColor: .systemRed) : Color(uiColor: .systemGreen))
                    .font(.headline)
            }
        }
        .padding(.vertical)
    }

    private var settledBalance: some View {
        Text("Settled")
            .foregroundColor(Color(uiColor: .systemGray))
            .padding(.vertical)
    }

    private var infoButton: some View {
        Button(action: onTapOfInfo ?? { }) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
        }
    }
}

struct GroupSummaryOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GroupSummaryOverlayView(balances: [
                .init(currency: .eur, amount: 102.12),
                .init(currency: .krw, amount: -10_092_793),
                .init(currency: .chf, amount: 23)
            ])
            GroupSummaryOverlayView(balances: [
                .init(currency: .jpy, amount: 193010)
            ])
            GroupSummaryOverlayView(balances: [])
        }
        .padding()
    }
}
