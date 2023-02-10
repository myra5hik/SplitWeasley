//
//  Loadable.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 09/02/23.
//

import Foundation

enum Loadable<T, E: Error> {
    case loaded(T)
    case loading
    case error(E)
}
