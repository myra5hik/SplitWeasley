//
//  WeaklyCaptured.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 01/02/23.
//

import Foundation

struct WeaklyCaptured<C: AnyObject> {
    var isAlive: Bool { capture != nil }
    weak private(set) var capture: C?

    init(capture: C) {
        self.capture = capture
    }
}
