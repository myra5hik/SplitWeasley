//
//  GroupSummaryLayoverView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/01/23.
//

import SwiftUI

struct GroupSummaryLayoverView: View {
    private let balances: [MonetaryAmount]
    private let onTapOfInfo: (() -> Void)?

    init(balances: [MonetaryAmount], onTapOfInfo: (() -> Void)? = nil) {
        self.balances = balances
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
    }

    @ViewBuilder
    private var balanceTexts: some View {
        if balances.isEmpty {
            settledBalance
        } else {
            nonSettledBalance
        }
    }

    private var nonSettledBalance: some View {
        VStack(alignment: .trailing) {
            ForEach(balances, id: \.hashValue) { amount in
                let negative = amount.amount < 0.0
                Text(amount.formatted())
                    .foregroundColor(negative ? Color(uiColor: .systemRed) : Color(uiColor: .systemGreen))
                    .font(.headline)
            }
        }
        .padding(.vertical)
    }

    private var settledBalance: some View {
        Text("You are settled")
            .foregroundColor(Color(uiColor: .systemGray))
            .padding(.vertical)
    }

    private var infoButton: some View {
        Button(action: onTapOfInfo ?? { }) {
            Image(systemName: "info.circle")
        }
    }
}

struct GroupSummaryLayoverView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GroupSummaryLayoverView(balances: [
                .init(currency: .eur, amount: 102.12),
                .init(currency: .chf, amount: 23),
                .init(currency: .krw, amount: -10_092_793)
            ])
            GroupSummaryLayoverView(balances: [
                .init(currency: .jpy, amount: 193010)
            ])
            GroupSummaryLayoverView(balances: [])
        }
        .padding()
    }
}
