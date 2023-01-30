//
//  CategoryIconFactory.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 30/01/23.
//

import SwiftUI

final class CategoryIconFactory: IIconFactory {
    typealias Model = TransactionCategory

    private static var otherIcon: Image {
        Image(systemName: "questionmark.folder.fill")
    }

    func icon(for category: Model) -> Image {
        switch category {
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

    func foregroundColor(for category: Model) -> Color {
        return category.grouping == .undefined ? .black : .white
    }

    func backgroundColor(for category: Model) -> Color {
        return groupingColor(for: category.grouping)
    }

    private func groupingColor(for group: TransactionCategory.Grouping) -> Color {
        switch group {
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
