//
//  ProfilePictureService.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 09/02/23.
//

import UIKit

// MARK: - IProfilePictureService Protocol

protocol IProfilePictureService: AnyObject {
    func picture(for: Person.ID) async throws -> UIImage?
}

// MARK: - Stub Implementation Async

///
/// Provides stubbed data in a async manner, simulating data loaded over network.
///
final class StubAsyncProfilePictureService: IProfilePictureService {
    @ThreadSafe(asyncWrites: false) private var stubPictures = [
        UIImage(named: "StubPic1"),
        UIImage(named: "StubPic2"),
        UIImage(named: "StubPic3"),
        UIImage(named: "StubPic4")
    ]
    @ThreadSafe private var cache = [Person.ID: UIImage?]()
    @ThreadSafe(asyncWrites: false) private var currentTasks = [Person.ID: Task<UIImage?, Never>]()

    func picture(for personId: Person.ID) async -> UIImage? {
        if let cached = cache[personId] { return cached }
        return await pseudoLoad(id: personId)
    }

    private func pseudoLoad(id: Person.ID) async -> UIImage? {
        if let executed = currentTasks[id] { return await executed.value }

        currentTasks[id] = Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return nil }
            let picture = !stubPictures.isEmpty ? stubPictures.removeFirst() : nil
            let delay = Duration.seconds(Double.random(in: 0.5 ... 2.0))
            try? await Task.sleep(for: delay)
            cache[id] = picture
            currentTasks[id] = nil
            return picture
        }

        return await currentTasks[id]?.value
    }
}

// MARK: - Stub Implementation Sync

///
/// Provides stubbed data in a sync manner, to be used in Previews.
///
final class StubSyncProfilePictureService: IProfilePictureService {
    static private var stubPictures = [
        UIImage(named: "StubPic1"),
        UIImage(named: "StubPic2"),
        UIImage(named: "StubPic3"),
        UIImage(named: "StubPic4")
    ]

    func picture(for: Person.ID) async throws -> UIImage? {
        return Self.stubPictures.randomElement() ?? .init()
    }
}
