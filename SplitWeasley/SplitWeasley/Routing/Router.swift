//
//  Router.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 04.01.2023.
//

import SwiftUI

// MARK: - IRouter Protocol

protocol IRouter: AnyObject {
    associatedtype RD: IRoutingDestination
    associatedtype V: View

    var rootView: V { get }

    func push(_ destination: RD)
    func pop()
    func present(_ destination: RD)
    func dismiss()
}

// MARK: - Router Implementation

final class Router<RD: IRoutingDestination>: IRouter {
    let rootView: PresentingView<RD>

    init(root: RD) {
        self.rootView = PresentingView(root: root)
    }

    func push(_ destination: RD) {
        rootView.push(destination)
    }

    func pop() {
        rootView.pop()
    }

    func present(_ destination: RD) {
        rootView.present(destination)
    }

    func dismiss() {
        rootView.dismiss()
    }
}
