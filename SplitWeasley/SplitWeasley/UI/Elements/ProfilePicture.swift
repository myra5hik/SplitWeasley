//
//  ProfilePicture.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 09/02/23.
//

import SwiftUI

struct ProfilePicture<S: IProfilePictureService>: View {
    // Data
    @State private var loadable: Loadable<UIImage?, Error> = .loading
    private let personId: Person.ID
    // Dependencies
    private let service: S

    init(service: S, personId: Person.ID) {
        self.service = service
        self.personId = personId
    }

    var body: some View {
        LoadableImage(loadable: loadable)
            .clipShape(Circle())
            .task { await requestPicture() }
    }

    private func requestPicture() async {
        do {
            guard let picture = try await service.picture(for: personId) else {
                loadable = .loaded(UIImage(systemName: "person.fill")); return
            }
            loadable = .loaded(picture)
        } catch {
            loadable = .error(error)
        }
    }
}

// MARK: - Preview

struct ProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicture(service: StubSyncProfilePictureService(), personId: SplitGroup.stub.members[0].id)
            .frame(width: 150, height: 150)
    }
}
