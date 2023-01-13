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
    associatedtype F: IScreenFactory

    var navigationPath: NavigationPath { get set }
    var presentedView: F.RD? { get set }

    func push(_ destination: F.RD)
    func pop()
    func present(_ destination: F.RD)
    func dismiss()
}

// MARK: - IScreenFactory protocol

protocol IScreenFactory: AnyObject {
    associatedtype RD: IRoutingDestination
    func view(for: RD) -> AnyView
}

// MARK: - Router Implementation

final class Router<F: IScreenFactory>: IRouter {
    @Published var navigationPath = NavigationPath()
    @Published var presentedView: F.RD?

    func push(_ destination: F.RD) {
        navigationPath.append(destination)
    }

    func pop() {
        navigationPath.removeLast()
    }

    func present(_ destination: F.RD) {
        presentedView = destination
    }

    func dismiss() {
        presentedView = nil
    }
}

// MARK: - Stub Router Implementation

final class StubRouter<F: IScreenFactory>: IRouter {
    var navigationPath = NavigationPath()
    var presentedView: F.RD?

    func push(_ destination: F.RD) { }
    func pop() { }
    func present(_ destination: F.RD) { }
    func dismiss() { }
}
