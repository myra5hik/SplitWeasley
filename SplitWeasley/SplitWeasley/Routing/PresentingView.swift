//
//  PresentingView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 05.01.2023.
//

import SwiftUI

struct PresentingView<R: IRouter, F: IScreenFactory>: View where R.RD == F.RD {
    @ObservedObject private var router: R // Router
    private let factory: F // Factory
    private let root: R.RD // Router.RoutingDestination

    init(router: R, factory: F, root: R.RD) {
        self.router = router
        self.factory = factory
        self.root = root
    }

    var body: some View {
        // Navigation
        NavigationStack(path: $router.navigationPath) {
            factory.view(for: root).navigationDestination(for: R.RD.self) { factory.view(for: $0) }
        }
        // Presentation
        .sheet(item: $router.presentedView) {
            factory.view(for: $0)
        }
    }
}
