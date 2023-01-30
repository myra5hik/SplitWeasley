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
    }
}

// MARK: - IIconDescribable Conformance

extension TransactionCategory: IIconDescribable {
    static let iconFactory = CategoryIconFactory()
}
