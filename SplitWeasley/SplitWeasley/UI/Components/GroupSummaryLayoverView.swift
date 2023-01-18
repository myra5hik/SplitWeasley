//
//  GroupSummaryLayoverView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/01/23.
//

import SwiftUI

struct GroupSummaryLayoverView: View {
    let balances: [MonetaryAmount]

    var body: some View {
        HStack {
            headingText
            Spacer()
            balanceTexts
        }
        .background(content: { background })
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 6)
            .foregroundColor(Color(uiColor: .tertiarySystemFill))
    }

    private var headingText: some View {
        Text("Your balances:")
            .font(.headline)
            .padding()
    }

    private var balanceTexts: some View {
        VStack(alignment: .trailing) {
            ForEach(balances, id: \.hashValue) { amount in
                let negative = amount.amount < 0.0
                Text(amount.formatted())
                    .foregroundColor(negative ? Color(uiColor: .systemRed) : Color(uiColor: .systemGreen))
                    .font(.headline)
            }
        }
        .padding()
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
        }
        .padding()
    }
}
