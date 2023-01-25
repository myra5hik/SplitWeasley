//
//  TransactionCell.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 19/01/23.
//

import SwiftUI

struct TransactionCell: View {
    let description: String
    let category: TransactionCategory
    let total: MonetaryAmount
    let balance: MonetaryAmount?
    let paidBy: PaidByDescriptor
    /// From 0.0 to 1.0 meaning 0% to 100%
    let currentUserSplitShare: Decimal
    let onTap: (() -> Void)?

    init(
        description: String,
        category: TransactionCategory,
        total: MonetaryAmount,
        balance: MonetaryAmount?,
        paidBy: PaidByDescriptor,
        currentUserSplitShare: Decimal,
        onTap: (() -> Void)? = nil
    ) {
        self.description = description
        self.category = category
        self.total = total
        self.balance = balance
        self.paidBy = paidBy
        self.currentUserSplitShare = currentUserSplitShare
        self.onTap = onTap
    }

    var body: some View {
        ConfugurableListRowView(
            heading: description,
            subheading: subheading,
            leadingAccessory: { icon },
            trailingAccessory: { balanceTextView },
            action: onTap
        )
    }

    // MARK: Components

    private var icon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .infinity)
                .foregroundColor(category.backgroundColor)
            category.icon
                .foregroundColor(category.foregroundColor)
        }
    }

    private var balanceTextView: some View {
        guard let balance = balance else {
            let zeroFormatted = MonetaryAmount(currency: total.currency).formatted()
            return Text("\(zeroFormatted)").foregroundColor(Color(uiColor: .systemGray3))
        }

        let color: UIColor = {
            if balance.amount < 0.0 { return .systemRed }
            if balance.amount > 0.0 { return .systemGreen }
            return .systemGray
        }()

        return Text(balance.formatted())
            .foregroundColor(Color(uiColor: color))
            .bold()
    }

    private var subheading: String {
        guard balance != nil else { return "You were not involved" }
        let totalFormatted = total.formatted()

        switch paidBy {
        case .currentUser:
            // Reverses the number to form the sentence "You lent '(1 - your share)'%"
            let percentage = 1 - currentUserSplitShare
            let percentageFormatted = percentage.formatted(.percent.precision(.fractionLength(0...1)))
            return "You paid \(totalFormatted), lending \(percentageFormatted)"
        case .other(name: let name):
            let percentageFormatted = currentUserSplitShare.formatted(.percent.precision(.fractionLength(0...1)))
            return "\(name) paid \(totalFormatted), lending you \(percentageFormatted)"
        case .multiplePeople:
            return "Several people paid \(totalFormatted)"
        }
    }
}

// MARK: - PaidByDescriptor

extension TransactionCell {
    enum PaidByDescriptor {
        case currentUser
        case other(name: String)
        case multiplePeople
    }
}

// MARK: - Previews

struct TransactionCell_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                TransactionCell(
                    description: "Plane tickets NAP-IST-NAP",
                    category: .sports,
                    total: MonetaryAmount(currency: .gbp, amount: 234.56),
                    balance: MonetaryAmount(currency: .gbp, amount: 123.45),
                    paidBy: .currentUser,
                    currentUserSplitShare: 0.12345
                )
                TransactionCell(
                    description: "Plane tickets NAP-IST-NAP",
                    category: .games,
                    total: MonetaryAmount(currency: .eur, amount: 234.56),
                    balance: MonetaryAmount(currency: .eur, amount: -123.45),
                    paidBy: .other(name: "John A."),
                    currentUserSplitShare: 0.12345
                )
                TransactionCell(
                    description: "Plane tickets NAP-IST-NAP",
                    category: .liquor,
                    total: MonetaryAmount(currency: .usd, amount: 234.56),
                    balance: MonetaryAmount(currency: .usd, amount: -123.45),
                    paidBy: .multiplePeople,
                    currentUserSplitShare: 0.33333
                )
            }
            .padding()
        }
    }
}
