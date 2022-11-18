//
//  Person.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 18/11/22.
//

import Foundation

struct Person: Identifiable, Hashable {
    let id: UUID

    let firstName: String
    let lastName: String?
    var fullName: String {
        var res = firstName
        if let lastName = lastName { res += " "; res += lastName }
        return res
    }
}
