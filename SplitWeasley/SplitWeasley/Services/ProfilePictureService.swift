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
    static private var stubPictures = [
        UIImage(named: "StubPic1"),
        UIImage(named: "StubPic2"),
        UIImage(named: "StubPic3"),
        UIImage(named: "StubPic4")
    ]

    private var cache = [Person.ID: UIImage]()
    private var currentTasks = [Person.ID: Task<UIImage?, Never>]()

    func picture(for personId: Person.ID) async -> UIImage? {
        if let cached = cache[personId] { return cached }
        return await pseudoLoad(id: personId)
    }

    private func pseudoLoad(id: Person.ID) async -> UIImage? {
        if let executed = currentTasks[id] { return try? await executed.result.get() }

        let task = Task(priority: .userInitiated) { [weak self] in
            guard !Self.stubPictures.isEmpty else { return UIImage?.none }
            let picture = Self.stubPictures.removeFirst()
            let delay = Duration(
                secondsComponent: Int64.random(in: 1 ... 2),
                attosecondsComponent: Int64.random(in: -9_999_999 ... 9_999_999)
            )
            try? await Task.sleep(for: delay)
            self?.cache[id] = picture
            currentTasks[id] = nil
            return picture
        }

        currentTasks[id] = task
        return await task.value
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
