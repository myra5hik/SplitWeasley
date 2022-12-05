//
//  TransactionCategory.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 03/12/22.
//

import SwiftUI

enum TransactionCategory: String, CaseIterable, Hashable, Identifiable, Codable {
    // Identifiable conformance
    var id: String { self.rawValue }

    // Entertainment
    case games
    case movies
    case music
    case sports
    case otherEntertainment
    // Food and Drink
    case diningOut
    case groceries
    case liquor
    case otherFoodAndDrink
    // Undefined
    case otherUndefined

    var grouping: Grouping {
        switch self {
        case .games, .movies, .music, .sports, .otherEntertainment: return .entertainment
        case .diningOut, .groceries, .liquor, .otherFoodAndDrink: return .foodAndDrink
        case .otherUndefined: return .undefined
        }
    }

    var icon: Image {
        switch self {
        // Entertainment
        case .games: return Image(systemName: "gamecontroller.fill")
        case .movies: return Image(systemName: "popcorn.fill")
        case .music: return Image(systemName: "music.quarternote.3")
        case .sports: return Image(systemName: "tennisball.fill")
        case .otherEntertainment: return Self.otherIcon
        // Food and Drink
        case .diningOut: return Image(systemName: "fork.knife")
        case .groceries: return Image(systemName: "basket.fill")
        case .liquor: return Image(systemName: "wineglass.fill")
        case .otherFoodAndDrink: return Self.otherIcon
        // Undefined
        case .otherUndefined: return Self.otherIcon
        }
    }

    private static var otherIcon: Image {
        Image(systemName: "questionmark.folder.fill")
    }

    var foregroundColor: Color {
        return grouping == .undefined ? .black : .white
    }

    var backgroundColor: Color {
        return grouping.color
    }
}

// MARK: - Grouping

extension TransactionCategory {
    enum Grouping: String, CaseIterable, Hashable, Identifiable, Codable {
        var id: String { self.rawValue }

        case entertainment
        case foodAndDrink
        case undefined

        var color: Color {
            switch self {
            case .entertainment: return Color(uiColor: .systemPurple).opacity(0.75)
            case .foodAndDrink: return Color(uiColor: .systemGreen).opacity(0.75)
            case .undefined: return Color(.white).opacity(0.75)
            }
        }
    }
}
