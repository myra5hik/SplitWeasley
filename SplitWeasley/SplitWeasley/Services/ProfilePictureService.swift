//
//  ProfilePictureService.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 09/02/23.
//

import UIKit

// MARK: - IProfilePictureService Protocol

protocol IProfilePictureService {
    func picture(for: Person.ID) async -> UIImage?
}

// MARK: - Stub Implementation

final class StubProfilePictureService: IProfilePictureService {
    static private var stubPictures = [
        UIImage(named: "StubPic1"),
        UIImage(named: "StubPic2"),
        UIImage(named: "StubPic3"),
        UIImage(named: "StubPic4")
    ]

    private var cache = [Person.ID: UIImage]()

    func picture(for personId: Person.ID) async -> UIImage? {
        if let cached = cache[personId] { return cached }
        return await pseudoLoad(id: personId)
    }

    private func pseudoLoad(id: Person.ID) async -> UIImage? {
        let picture = Self.stubPictures.randomElement() ?? nil
        let delay = UInt32.random(in: 1...3)
        sleep(delay)
        cache[id] = picture
        return picture
    }
}
