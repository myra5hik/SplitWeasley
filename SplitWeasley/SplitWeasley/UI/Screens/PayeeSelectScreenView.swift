//
//  PayeeSelectScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 10/02/23.
//

import SwiftUI

struct PayeeSelectScreenView<PPS: IProfilePictureService>: View {
    // Data
    let group: SplitGroup
    // Dependencies
    private let service: PPS
    // Actions
    private let onSelect: ((Person) -> Void)?
    private let onCancel: (() -> Void)?

    init(
        group: SplitGroup,
        service: PPS,
        onSelect: ((Person) -> Void)? = nil,
        onTapOfCancel: (() -> Void)? = nil
    ) {
        self.group = group
        self.service = service
        self.onSelect = onSelect
        self.onCancel = onTapOfCancel
    }

    var body: some View {
        NavigationView {
            List(group.members, id: \.id) { payee in
                ConfugurableListRowView(
                    heading: payee.fullName,
                    subheading: nil,
                    leadingAccessory: { ProfilePicture(service: service, personId: payee.id) },
                    action: { onSelect?(payee) }
                )
            }
            .navigationTitle("Select Person Paying")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { cancelButton }
        }
    }

    private var cancelButton: some View {
        Button("Cancel", action: onCancel ?? { })
    }
}

// MARK: - Previews

struct PayeeSelectScreenView_Previews: PreviewProvider {
    static var previews: some View {
        PayeeSelectScreenView(group: SplitGroup.stub, service: StubSyncProfilePictureService())
    }
}
