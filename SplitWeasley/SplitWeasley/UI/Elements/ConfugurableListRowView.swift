//
//  ConfugurableListRowView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 20/11/22.
//

import SwiftUI

struct ConfugurableListRowView<LA: View, TA: View>: View {
    // State
    private let heading: String
    private let subheading: String?
    private let leadingAccessory: () -> LA
    private let trailingAccessory: () -> TA
    // Action
    private let action: (() -> Void)?

    init(
        heading: String,
        subheading: String? = nil,
        @ViewBuilder leadingAccessory: @escaping () -> LA = { EmptyView() },
        @ViewBuilder trailingAccessory: @escaping () -> TA = { EmptyView() },
        action: (() -> Void)? = nil
    ) {
        self.heading = heading
        self.subheading = subheading
        self.leadingAccessory = leadingAccessory
        self.trailingAccessory = trailingAccessory
        self.action = action
    }

    var body: some View {
        Button(action: action ?? { }, label: {
            HStack {
                leadingAccessory().frame(width: 36, height: 36)
                VStack(alignment: .leading) {
                    Text(heading)
                    if let subheading = subheading {
                        Text(subheading)
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                            .foregroundColor(Color(uiColor: .systemGray))
                    }
                }
                Spacer()
                trailingAccessory()
            }
        })
        .foregroundColor(Color(uiColor: UIColor.label))
    }
}

struct ConfugurableListRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ConfugurableListRowView(heading: "Plain")
            ConfugurableListRowView(heading: "Heading", subheading: "with subheading")
            ConfugurableListRowView(
                heading: "Full",
                subheading: "including subline",
                leadingAccessory: { Circle().foregroundColor(.mint) },
                trailingAccessory: { Image(systemName: "checkmark") }
            )
            ConfugurableListRowView(
                heading: "Full",
                subheading: "including a lengthy subline, the on of inadequate length, taking multiple rows",
                leadingAccessory: { Circle().foregroundColor(.mint) },
                trailingAccessory: { Image(systemName: "checkmark") }
            )
        }
    }
}
