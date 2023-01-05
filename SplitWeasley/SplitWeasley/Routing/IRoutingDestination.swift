//
//  IRoutingDestination.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 06.01.2023.
//

import SwiftUI

protocol IRoutingDestination: Identifiable, Hashable {
    func view() -> AnyView
}
