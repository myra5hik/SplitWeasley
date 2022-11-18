//
//  Currency.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/11/22.
//

import SwiftUI

enum Currency: Hashable, CaseIterable {
    case usd
    case eur
}

// MARK: - Codes

extension Currency {
    var iso4217code: String {
        return "\(self)".uppercased()
    }
}

// MARK: - Full names

extension Currency {
    var name: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        }
    }
}

// MARK: - Icons

extension Currency {
    private static var defaultIcon: UIImage { UIImage(systemName: "questionmark")! }

    var icon: UIImage {
        switch self {
        case .usd: return UIImage(systemName: "dollarsign") ?? Self.defaultIcon
        case .eur: return UIImage(systemName: "eurosign") ?? Self.defaultIcon
        }
    }
}
