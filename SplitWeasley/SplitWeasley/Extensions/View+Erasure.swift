//
//  View+Erasure.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 09.01.2023.
//

import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}
