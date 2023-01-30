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

    // Undefined
    case undefined
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
    // Home
    case electronics
    case furniture
    case householdSupplies
    case maintenance
    case mortgage
    case pets
    case rent
    case services
    case otherHome
    // Life
    case childcare
    case clothing
    case education
    case gifts
    case insurance
    case medicalExpenses
    case taxes
    case otherLife
    // Transportation
    case bicycle
    case busOrTrain
    case car
    case gasOrFuel
    case hotel
    case parking
    case plane
    case taxi
    case otherTransportation
    // Utilities
    case cleaning
    case electricity
    case heatOrGas
    case trash
    case televisionOrPhoneOrInternet
    case otherUtilities

    var grouping: Grouping {
        switch self {
        // Undefined
        case .undefined:
            return .undefined
        // Entertainment
        case .games, .movies, .music, .sports, .otherEntertainment:
            return .entertainment
        // Food and Drink
        case .diningOut, .groceries, .liquor, .otherFoodAndDrink:
            return .food
        // Home
        case .electronics, .furniture, .householdSupplies, .maintenance, .mortgage, .pets, .rent, .services, .otherHome:
            return .home
        // Life
        case .childcare, .clothing, .education, .gifts, .insurance, .medicalExpenses, .taxes, .otherLife:
            return .life
        // Transportation
        case .bicycle, .busOrTrain, .car, .gasOrFuel, .hotel, .parking, .plane, .taxi, .otherTransportation:
            return .transportation
        // Utilities
        case .cleaning, .electricity, .heatOrGas, .trash, .televisionOrPhoneOrInternet, .otherUtilities:
            return .utilities
        }
    }

    var icon: Image {
        switch self {
        // Undefined
        case .undefined: return Self.otherIcon
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
        // Home
        case .electronics: return Image(systemName: "tv")
        case .furniture: return Image(systemName: "sofa.fill")
        case .householdSupplies: return Image(systemName: "shower")
        case .maintenance: return Image(systemName: "hammer.fill")
        case .mortgage: return Image(systemName: "house.fill")
        case .pets: return Image(systemName: "pawprint.fill")
        case .rent: return Image(systemName: "house.fill")
        case .services: return Image(systemName: "bell.fill")
        case .otherHome: return Image(systemName: "house.fill")
        // Life
        case .childcare: return Image(systemName: "figure.and.child.holdinghands")
        case .clothing: return Image(systemName: "figure.dance")
        case .education: return Image(systemName: "book.fill")
        case .gifts: return Image(systemName: "gift.fill")
        case .insurance: return Image(systemName: "doc.append.fill")
        case .medicalExpenses: return Image(systemName: "medical.thermometer.fill")
        case .taxes: return Image(systemName: "building.columns.fill")
        case .otherLife: return Image(systemName: "heart.fill")
        // Transportation
        case .bicycle: return Image(systemName: "bicycle")
        case .busOrTrain: return Image(systemName: "train.side.front.car")
        case .car: return Image(systemName: "car.fill")
        case .gasOrFuel: return Image(systemName: "fuelpump.fill")
        case .hotel: return Image(systemName: "building.2.fill")
        case .parking: return Image(systemName: "parkingsign.circle.fill")
        case .plane: return Image(systemName: "airplane")
        case .taxi: return Image(systemName: "t.circle.fill")
        case .otherTransportation: return Image(systemName: "arrow.left.arrow.right")
        // Utilities
        case .cleaning: return Image(systemName: "bubbles.and.sparkles.fill")
        case .electricity: return Image(systemName: "bolt.fill")
        case .heatOrGas: return Image(systemName: "flame")
        case .trash: return Image(systemName: "trash")
        case .televisionOrPhoneOrInternet: return Image(systemName: "wifi")
        case .otherUtilities: return Image(systemName: "lightbulb.2.fill")
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

    var description: String {
        let caseString = "\(self)"
        // Returns a concise "Other" for all 'other...' cases
        if caseString.hasPrefix("other") { return "Other" }
        // Returns a string with each word capitalized, as split by camelCase convention
        var res = [""]
        for c in caseString {
            if c.isUppercase { res.append("") }
            res[res.endIndex - 1].append(String(c).lowercased())
        }
        // Makes strings capitalized
        for i in res.indices {
            let str = res[i]
            if str == "and" || str == "or" {
                res[i] = res[i].lowercased()
            } else {
                res[i] = res[i].capitalized
            }
        }

        return res.joined(separator: " ")
    }
}

// MARK: - Grouping

extension TransactionCategory {
    enum Grouping: String, CaseIterable, Hashable, Identifiable, Codable {
        var id: String { self.rawValue }

        case undefined
        case entertainment
        case food
        case home
        case life
        case transportation
        case utilities

        var color: Color {
            switch self {
            case .undefined: return Color(.white).opacity(0.75)
            case .entertainment: return Color(uiColor: .systemPurple).opacity(0.75)
            case .food: return Color(uiColor: .systemGreen).opacity(0.75)
            case .home: return Color(uiColor: .systemYellow).opacity(0.75)
            case .life: return Color(uiColor: .systemOrange).opacity(0.75)
            case .transportation: return Color(uiColor: .systemPink).opacity(0.75)
            case .utilities: return Color(uiColor: .systemBlue).opacity(0.75)
            }
        }
    }
}
