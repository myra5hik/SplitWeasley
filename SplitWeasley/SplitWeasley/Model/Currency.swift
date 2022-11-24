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
    case jpy
    case gbp
    case cny
    case aud
    case cad
    case chf
    case hkd
    case sgd
    case rub
    case btc
}

// MARK: - Identifiable

extension Currency: Identifiable {
    var id: Self { self }
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
        case .jpy: return "Japanese Yen"
        case .gbp: return "British Pound"
        case .cny: return "Renminbi"
        case .aud: return "Australian Dollar"
        case .cad: return "Canadian Dollar"
        case .chf: return "Swiss Franc"
        case .hkd: return "Hong Kong Dollar"
        case .sgd: return "Singapore Dollar"
        case .rub: return "Russian Ruble"
        case .btc: return "Bitcoin"
        }
    }
}

// MARK: - Rounding scales

extension Currency {
    var roundingScale: Int {
        switch self {
        case .usd: return 2
        case .eur: return 2
        case .jpy: return 0
        case .gbp: return 2
        case .cny: return 2
        case .aud: return 2
        case .cad: return 2
        case .chf: return 2
        case .hkd: return 2
        case .sgd: return 2
        case .rub: return 2
        case .btc: return 8
        }
    }
}

// MARK: - Icons

extension Currency {
    var iconString: String {
        switch self {
        case .usd: return "dollarsign"
        case .eur: return "eurosign"
        case .jpy: return "yensign"
        case .gbp: return "sterlingsign"
        case .cny: return "yensign"
        case .aud: return "australsign"
        case .cad: return "dollarsign"
        case .chf: return "francsign"
        case .hkd: return "dollarsign"
        case .sgd: return "dollarsign"
        case .rub: return "rublesign"
        case .btc: return "bitcoinsign"
        }
    }
}
