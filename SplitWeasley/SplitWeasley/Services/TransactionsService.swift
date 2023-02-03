//
//  TransactionsService.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 01/02/23.
//

import Foundation

// MARK: - ITransactionsService Protocol

protocol ITransactionsService {
    associatedtype ObservableBox: IObservableTransactionsBox

    func subscribe(to: SplitGroup.ID) -> ObservableBox
    func add(transaction: SplitTransaction)
}

// MARK: - TransactionsService implementation

final class TransactionsService {
    // Data
    private var transactions: [SplitGroup.ID: [SplitTransaction]]
    // Subscriptions
    private var subscriptions = [SplitGroup.ID: WeaklyCaptured<ObservableTransactionsBox>]()

    init() {
        self.transactions = [SplitGroup.stub.id: SplitTransaction.stub]
    }
}

// MARK: - ITransactionsService Conformance

extension TransactionsService: ITransactionsService {
    typealias ObservableBox = ObservableTransactionsBox
    ///
    /// Returns a weakly captured box which will deallocate as soon as the client class stops holding it
    ///
    func subscribe(to groupId: SplitGroup.ID) -> ObservableTransactionsBox {
        let box: ObservableTransactionsBox

        if let subscription = subscriptions[groupId], let captured = subscription.capture {
            box = captured
        } else {
            box = ObservableTransactionsBox(groupId: groupId)
            subscriptions[groupId] = WeaklyCaptured(capture: box)
            update(box: box, with: transactions[groupId] ?? [])
        }

        sanitizeSubscriptions()
        return box
    }

    func add(transaction: SplitTransaction) {
        let groupId = transaction.group.id
        transactions[groupId]?.append(transaction)
        if let subscription = subscriptions[groupId] {
            update(box: subscription.capture, with: transactions[groupId] ?? [])
        }
        sanitizeSubscriptions()
    }
}

// MARK: - Data Transformations

private extension TransactionsService {
    func update(box: ObservableTransactionsBox?, with transactions: [SplitTransaction]) {
        guard let box = box else { return }

        Task(priority: .userInitiated) { [weak self] in
            guard let groupings = await self?.calculateGroupings(transactions) else { return }
            guard let balances = await self?.calculateBalances(transactions) else { return }

            DispatchQueue.main.async {
                box.transactions = transactions
                box.groupings = groupings
                box.balances = balances
            }
        }
    }

    func calculateGroupings(_ transactions: [SplitTransaction]) async -> [Date: [SplitTransaction]] {
        var res = [Date: [SplitTransaction]]()
        // Groups into a dictionary, one array per a day
        for transaction in transactions {
            let roundedDate = Calendar.current.startOfDay(for: transaction.datePerformed)
            res[roundedDate, default: []].append(transaction)
        }
        // Sorts transactions latest to top
        for (key, array) in res {
            res[key] = array.sorted(by: { $0.datePerformed >= $1.datePerformed })
        }
        return res
    }

    func calculateBalances(_ transactions: [SplitTransaction]) async -> [Person.ID: [MonetaryAmount]] {
        var res = [Person.ID: [Currency: MonetaryAmount]]()

        for transaction in transactions {
            let currency = transaction.total.currency
            for person in transaction.group.members {
                guard let balance = transaction.balance(of: person.id) else { continue }
                let oldBalance = res[person.id]?[currency]?.amount ?? 0.0
                let newBalance = balance.with(amount: balance.amount + oldBalance)
                res[person.id, default: [:]][currency] = newBalance
            }
        }

        var flattened = [Person.ID: [MonetaryAmount]]()
        for (key, dict) in res { flattened[key] = Array(dict.values) }

        return flattened
    }

    func sanitizeSubscriptions() {
        for (key, box) in subscriptions {
            if !box.isAlive { subscriptions[key] = nil }
        }
    }
}

// MARK: - Stub Implementation

final class StubTransactionsService: ITransactionsService {
    func subscribe(to: SplitGroup.ID) -> ObservableTransactionsBox {
        return ObservableTransactionsBox(
            groupId: SplitGroup.stub.id,
            transactions: SplitTransaction.stub,
            groupings: [Date(): SplitTransaction.stub],
            balances: [SplitGroup.stub.members[0].id: [MonetaryAmount(currency: .eur, amount: 1.23)]]
        )
    }

    func add(transaction: SplitTransaction) { }
}

// MARK: - ObservableTransactionsBox

///
/// Allows subscribing to relevant data without exposing all of the service's internal data
///
protocol IObservableTransactionsBox: ObservableObject {
    var groupId: SplitGroup.ID { get }
    var transactions: [SplitTransaction] { get }
    var groupings: [Date: [SplitTransaction]] { get }
    var balances: [Person.ID: [MonetaryAmount]] { get }
}

final class ObservableTransactionsBox: ObservableObject, IObservableTransactionsBox {
    let groupId: SplitGroup.ID

    @Published fileprivate(set) var transactions: [SplitTransaction]
    @Published fileprivate(set) var groupings: [Date: [SplitTransaction]]
    @Published fileprivate(set) var balances: [Person.ID: [MonetaryAmount]]

    init(
        groupId: SplitGroup.ID,
        transactions: [SplitTransaction] = [],
        groupings: [Date : [SplitTransaction]] = [:],
        balances: [Person.ID: [MonetaryAmount]] = [:]
    ) {
        self.groupId = groupId
        self.transactions = transactions
        self.groupings = groupings
        self.balances = balances
    }
}
