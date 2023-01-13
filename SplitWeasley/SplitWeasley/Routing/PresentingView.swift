//
//  PresentingView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 05.01.2023.
//

import SwiftUI

struct PresentingView<R: IRouter>: View {
    @ObservedObject private var router: R
    private let factory: R.F // Router.Factory
    private let root: R.F.RD // Router.Factory.RoutingDestination

    init(router: R, factory: R.F, root: R.F.RD) {
        self.router = router
        self.factory = factory
        self.root = root
    }

    var body: some View {
        // Navigation
        NavigationStack(path: $router.navigationPath) {
            factory.view(for: root).navigationDestination(for: R.F.RD.self) { factory.view(for: $0) }
        }
        // Presentation
        .sheet(item: $router.presentedView) {
            factory.view(for: $0)
        }
    }
}
