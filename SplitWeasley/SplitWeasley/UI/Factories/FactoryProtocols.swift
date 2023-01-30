//
//  FactoryProtocols.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 30/01/23.
//

import SwiftUI

// MARK: - Icons

protocol IIconFactory {
    associatedtype Model
    associatedtype V: View

    func icon(for: Model) -> V
    func foregroundColor(for: Model) -> Color
    func backgroundColor(for: Model) -> Color
}

protocol IIconDescribable {
    associatedtype IconFactory: IIconFactory where IconFactory.Model == Self

    static var iconFactory: IconFactory { get }
    var icon: IconFactory.V { get }
    var backgroundColor: Color { get }
    var foregroundColor: Color { get }
}

extension IIconDescribable {
    var icon: IconFactory.V { Self.iconFactory.icon(for: self) }
    var backgroundColor: Color { Self.iconFactory.backgroundColor(for: self) }
    var foregroundColor: Color { Self.iconFactory.foregroundColor(for: self) }
}
