//
//  PresentingView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 05.01.2023.
//

import SwiftUI

struct PresentingView<RD: IRoutingDestination>: View {
    @State private var navigationPath = NavigationPath()
    @State private var presentedView: RD?
    private let root: RD

    init(root: RD) {
        self.root = root
    }

    var body: some View {
        NavigationStack(path: $navigationPath, root: { root.view() })
            .navigationDestination(for: RD.self, destination: { $0.view() })
            .sheet(item: $presentedView, content: { $0.view() })
    }

    func push(_ destination: RD) {
        navigationPath.append(destination)
    }

    func pop() {
        navigationPath.removeLast()
    }

    func present(_ destination: RD) {
        presentedView = destination
    }

    func dismiss() {
        presentedView = nil
    }
}
