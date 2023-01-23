//
//  SplitGroup.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/11/22.
//

import Foundation

struct SplitGroup: Identifiable, Hashable {
    let id: UUID
    let members: [Person]
}

// MARK: - Stub data

extension SplitGroup {
    static var stub = SplitGroup(id: UUID(), members: [
        Person(id: UUID(), firstName: "John", lastName: "Appleseed"),
        Person(id: UUID(), firstName: "The Dude"),
        Person(id: UUID(), firstName: "Alex")
    ])
}
