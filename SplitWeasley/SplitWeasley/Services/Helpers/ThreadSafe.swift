//
//  ThreadSafe.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 29/05/23.
//

import Foundation

@propertyWrapper
final class ThreadSafe<T> {
    var wrappedValue: T {
        get {
            queue.sync { _wrapped }
        }
        set {
            if asyncWrites {
                queue.async(flags: .barrier) { [weak self] in self?._wrapped = newValue }
            } else {
                queue.sync(flags: .barrier) { [weak self] in self?._wrapped = newValue }
            }
        }
    }

    private var _wrapped: T
    private let asyncWrites: Bool
    private let queue: DispatchQueue

    /// ThreadSafe will create a new queue with this initialiser
    init(wrappedValue: T, qos: DispatchQoS? = nil, asyncWrites: Bool = true) {
        self._wrapped = wrappedValue
        self.asyncWrites = asyncWrites
        self.queue = DispatchQueue(
            label: "com.myra5hik.SplitWeasley.ThreadSafe<\(T.self)>.concurrent-q",
            qos: qos ?? .utility,
            attributes: .concurrent
        )
    }

    /// ThreadSafe will use the provided queue, holding a strong reference to it
    init(wrappedValue: T, queue: DispatchQueue, asyncWrites: Bool = true) {
        self._wrapped = wrappedValue
        self.queue = queue
        self.asyncWrites = asyncWrites
    }
}
