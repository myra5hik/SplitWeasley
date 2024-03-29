//
//  Router.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 04.01.2023.
//

import SwiftUI

// MARK: - IRoutingDestination Protocol

protocol IRoutingDestination: Identifiable, Hashable { }

// MARK: - IRouter Protocol

protocol IRouter: ObservableObject {
    associatedtype RD: IRoutingDestination

    var navigationPath: NavigationPath { get set }
    var presentedView: RD? { get set }

    /// Pushes a destination onto the NavigationStack
    func push(_ destination: RD)
    /// Pops a destination from the NavigationStack
    func pop()
    /// Presents a destination modally
    func present(_ destination: RD)
    /// Dismisses a modally presented destination
    func dismiss()
}

// MARK: - IScreenFactory protocol

protocol IScreenFactory: AnyObject {
    associatedtype RD: IRoutingDestination
    associatedtype V: View

    func view(for: RD) -> V
}

// MARK: - Router Implementation

final class Router<RD: IRoutingDestination>: IRouter {
    @Published var navigationPath = NavigationPath()
    @Published var presentedView: RD?

    func push(_ destination: RD) {
        navigationPath.append(destination)
    }

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func present(_ destination: RD) {
        presentedView = destination
    }

    func dismiss() {
        presentedView = nil
    }
}

// MARK: - Stub Router Implementation

final class StubRouter<RD: IRoutingDestination>: IRouter {
    var navigationPath = NavigationPath()
    var presentedView: RD?

    func push(_ destination: RD) { }
    func pop() { }
    func present(_ destination: RD) { }
    func dismiss() { }
}
