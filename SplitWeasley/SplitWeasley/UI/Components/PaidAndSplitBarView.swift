//
//  PaidAndSplitBarView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 16/11/22.
//

import SwiftUI

struct PaidAndSplitBarView: View {
    private let payeeLabel: String
    private let splitLabel: String
    private let payeeAction: (() -> Void)?
    private let splitAction: (() -> Void)?
    private let payeeButtonActive: Bool
    private let splitBubbonActive: Bool

    init(
        payeeLabel: String,
        splitLabel: String,
        payeeAction: (() -> Void)?,
        splitAction: (() -> Void)?,
        payeeButtonActive: Bool = true,
        splitButtonActive: Bool = true
    ) {
        self.payeeLabel = payeeLabel
        self.splitLabel = splitLabel
        self.payeeAction = payeeAction
        self.splitAction = splitAction
        self.payeeButtonActive = payeeButtonActive
        self.splitBubbonActive = splitButtonActive
    }

    var body: some View {
        HStack(spacing: 4) {
            Text("Paid by")
            Button(payeeLabel, action: payeeAction ?? { })
                .buttonStyle(.bordered)
                .disabled(!payeeButtonActive)
            Text("and split")
            Button(splitLabel, action: splitAction ?? { })
                .buttonStyle(.bordered)
                .disabled(!splitBubbonActive)
        }
        .tint(Color(uiColor: .label))
    }
}

// MARK: - Preview

struct PaidAndSplitBarView_Previews: PreviewProvider {
    static var previews: some View {
        PaidAndSplitBarView(
            payeeLabel: "you",
            splitLabel: "equally",
            payeeAction: nil,
            splitAction: nil
        )
        .previewLayout(.fixed(width: 300, height: 100))
    }
}
