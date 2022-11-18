//
//  PaidAndSplitBarView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 16/11/22.
//

import SwiftUI

struct PaidAndSplitBarView: View {
    @Binding var payeeLabel: String
    @Binding var splitLabel: String
    private let payeeAction: (() -> Void)?
    private let splitAction: (() -> Void)?

    init(
        payeeLabel: Binding<String>,
        splitLabel: Binding<String>,
        payeeAction: (() -> Void)?,
        splitAction: (() -> Void)?
    ) {
        self._payeeLabel = payeeLabel
        self._splitLabel = splitLabel
        self.payeeAction = payeeAction
        self.splitAction = splitAction
    }

    var body: some View {
        HStack(spacing: 4) {
            Text("Paid by")
            Button(payeeLabel, action: payeeAction ?? { })
                .buttonStyle(.bordered)
            Text("and split")
            Button(splitLabel, action: splitAction ?? { })
                .buttonStyle(.bordered)
        }
        .foregroundColor(Color(UIColor.label))
    }
}

// MARK: - Preview

struct PaidAndSplitBarView_Previews: PreviewProvider {
    static var previews: some View {
        PaidAndSplitBarView(
            payeeLabel: Binding<String>(get: { "you" }, set: { _ in }),
            splitLabel: Binding<String>(get: { "equally" }, set: { _ in }),
            payeeAction: nil,
            splitAction: nil
        )
        .previewLayout(.fixed(width: 300, height: 100))
    }
}
