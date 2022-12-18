//
//  TransactionCategorySelectionList.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 05/12/22.
//

import SwiftUI

struct TransactionCategorySelectionList: View {
    // Action
    private let onSelect: ((TransactionCategory) -> Void)?

    init(onSelect: ((TransactionCategory) -> Void)? = nil) {
        self.onSelect = onSelect
    }

    var body: some View {
        List {
            ForEach(TransactionCategory.Grouping.allCases) { grouping in
                Section(grouping.rawValue) {
                    ForEach(TransactionCategory.allCases.filter({ $0.grouping == grouping })) { category in
                        cell(category)
                    }
                }
            }
        }
    }

    private func cell(_ category: TransactionCategory) -> some View {
        ConfugurableListRowView(
            heading: category.rawValue,
            leadingAccessory: {
                ZStack {
                    Circle()
                        .foregroundColor(category.backgroundColor).padding(.vertical, 2)
                    category.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(category.foregroundColor)
                        .padding(8)
                }
            },
            action: { onSelect?(category) }
        )
    }
}

// MARK: - Preview

struct TransactionCategorySelectionList_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCategorySelectionList()
    }
}
