//
//  ISplitStrategy.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 21/11/22.
//

import Foundation

protocol ISplitStrategy: ObservableObject {
    var splitGroup: SplitGroup { get }
    var total: MonetaryAmount { get set }
    /// Signifies that the applied parameters are consistent with the logic of the app. If false, views should not allow for further processing.
    var isLogicallyConsistent: Bool { get }
    /// Heading used by views to describe the split strategy
    var hintHeader: String { get }
    /// Text body used by views to describe the split strategy
    var hintDescription: String { get }
    /// One-word stretegy description used by views
    var conciseHintDescription: String { get }
    // Init
    init(splitGroup: SplitGroup, total: MonetaryAmount)
    /// Returns the amount split towards the person passed as parameter.
    func amount(for personId: Person.ID) -> MonetaryAmount?
}
