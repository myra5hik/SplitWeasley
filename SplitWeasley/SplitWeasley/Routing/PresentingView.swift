//
//  PresentingView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 05.01.2023.
//

import SwiftUI

struct PresentingView<R: IRouter, F: IScreenFactory>: View where R.RD == F.RD {
    @ObservedObject private var router: R // Router
    weak private var factory: F? // Factory
    private let root: R.RD // Router.RoutingDestination

    init(router: R, factory: F, root: R.RD) {
        self.router = router
        self.factory = factory
        self.root = root
    }

    var body: some View {
        // Navigation
        NavigationStack(path: $router.navigationPath) {
            makeView(for: root)
                .navigationDestination(for: R.RD.self, destination: { makeView(for: $0) })
        }
        // Presentation
        .sheet(item: $router.presentedView) {
            makeView(for: $0)
        }
    }

    @ViewBuilder
    private func makeView(for destination: R.RD) -> some View {
        if let factory = factory {
            factory.view(for: destination)
        } else {
            EmptyView()
        }
    }
}
