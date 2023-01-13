//
//  SplitWeasleyApp.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 16/11/22.
//

import SwiftUI

@main
struct SplitWeasleyApp: App {
    private let addTransactionModule = AddTransactionModule()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                addTransactionModule.rootView
            }
        }
    }
}
