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
