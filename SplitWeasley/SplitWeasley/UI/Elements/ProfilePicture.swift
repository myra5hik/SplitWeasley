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
        presentedView
            .clipShape(Circle())
            .task { await requestPicture() }
    }

    @ViewBuilder
    var presentedView: some View {
        if case .loaded(let loaded) = loadable, loaded == nil {
            Image(systemName: "person.fill")
                .resizable()
                .scaleEffect(x: 0.5, y: 0.5)
                .foregroundColor(Color(uiColor: .systemBackground))
                .background(Color(uiColor: .systemGray2))
        } else {
            LoadableImage(loadable: loadable)
        }
    }

    private func requestPicture() async {
        do {
            guard let picture = try await service.picture(for: personId) else {
                loadable = .loaded(nil); return
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
        let service = StubAsyncProfilePictureService()
        VStack {
            ProfilePicture(service: service, personId: SplitGroup.stub.members[0].id)
                .frame(width: 150, height: 150)
            ProfilePicture(service: service, personId: SplitGroup.stub.members[1].id)
                .frame(width: 150, height: 150)
            ProfilePicture(service: service, personId: SplitGroup.stub.members[2].id)
                .frame(width: 150, height: 150)
            ProfilePicture(service: service, personId: SplitGroup.stub.members[3].id)
                .frame(width: 150, height: 150)
            ProfilePicture(service: service, personId: UUID())
                .frame(width: 150, height: 150)
        }
    }
}
