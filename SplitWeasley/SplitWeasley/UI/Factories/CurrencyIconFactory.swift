//
//  CurrencyIconFactory.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 30/01/23.
//

import SwiftUI

final class CurrencyIconFactory: IIconFactory {
    func icon(for currency: Currency) -> Image {
        switch currency {
        case .usd: return Image(systemName: "dollarsign")
        case .eur: return Image(systemName: "eurosign")
        case .jpy: return Image(systemName: "yensign")
        case .gbp: return Image(systemName: "sterlingsign")
        case .cny: return Image(systemName: "yensign")
        case .aud: return Image(systemName: "australsign")
        case .cad: return Image(systemName: "dollarsign")
        case .chf: return Image(systemName: "francsign")
        case .hkd: return Image(systemName: "dollarsign")
        case .sgd: return Image(systemName: "dollarsign")
        case .rub: return Image(systemName: "rublesign")
        case .brl: return Image(systemName: "brazilianrealsign")
        case .inr: return Image(systemName: "indianrupeesign")
        case .krw: return Image(systemName: "wonsign")
        case .mxn: return Image(systemName: "pesosign")
        case .uah: return Image(systemName: "hryvniasign")
        case .btc: return Image(systemName: "bitcoinsign")
        }
    }

    func foregroundColor(for: Currency) -> Color {
        return Color(uiColor: .label)
    }

    func backgroundColor(for: Currency) -> Color {
        return Color(uiColor: .systemBackground)
    }
}
