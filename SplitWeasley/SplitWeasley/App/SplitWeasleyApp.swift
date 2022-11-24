//
//  SplitWeasleyApp.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 16/11/22.
//

import SwiftUI

@main
struct SplitWeasleyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SplitOptionsScreenView(
                    splitGroup: SplitGroup(id: UUID(), members: [
                        .init(id: UUID(), firstName: "Alexander"),
                        .init(id: UUID(), firstName: "Alena"),
                        .init(id: UUID(), firstName: "Ilia"),
                        .init(id: UUID(), firstName: "Oleg")
                    ]),
                    total: MonetaryAmount(currency: .eur, amount: 10.0)
                )
            }
        }
    }
}
