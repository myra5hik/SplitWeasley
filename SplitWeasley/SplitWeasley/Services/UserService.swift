//
//  UserService.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 06/02/23.
//

import Foundation

// MARK: - IUserService Protocol

protocol IUserService: ObservableObject {
    var currentUser: Person { get }
}

// MARK: - Stub Implementation

final class StubUserService: ObservableObject, IUserService {
    let currentUser = SplitGroup.stub.members[0]
}
