//
//  ScrollableLazyVStack.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 25/01/23.
//

import SwiftUI

struct ScrollableLazyVStack<V: View>: View {
    @ViewBuilder private let content: () -> V

    init(@ViewBuilder content: @escaping () -> V) {
        self.content = content
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                content()
            }
        }
    }
}

struct ScrollableLazyVStack_Previews: PreviewProvider {
    static var previews: some View {
        ScrollableLazyVStack {
            Text("Content")
        }
    }
}
