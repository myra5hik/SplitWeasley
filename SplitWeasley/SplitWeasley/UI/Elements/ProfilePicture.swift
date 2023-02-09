//
//  ProfilePicture.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 09/02/23.
//

import SwiftUI

struct ProfilePicture<S: IProfilePictureService>: View {
    // View model
    @StateObject private var vm: ViewModel<S>

    init(service: S, personId: Person.ID) {
        self._vm = .init(wrappedValue: ViewModel(service: service, personId: personId))
    }

    var body: some View {
        LoadableImage(loadable: vm.loadable)
            .clipShape(Circle())
    }
}

// MARK: - View Model

extension ProfilePicture {
    final class ViewModel<S: IProfilePictureService>: ObservableObject {
        // Data
        @Published private(set) var loadable: Loadable<UIImage?, Error> = .loading
        // Dependencies
        private let service: S

        init(service: S, personId: Person.ID) {
            self.service = service
            requestPicture(personId)
        }

        private func requestPicture(_ id: Person.ID) {
            Task(priority: .userInitiated) { [weak self] in
                do {
                    guard let service = self?.service else {
                        self?.loadable = .error(CancellationError())
                        return
                    }
                    guard let picture = try await service.picture(for: id) else {
                        let defaultPicture = UIImage(systemName: "person.fill")
                        self?.loadable = .loaded(defaultPicture ?? .init())
                        return
                    }
                    self?.loadable = .loaded(picture)
                } catch {
                    self?.loadable = .error(error)
                }
            }
        }
    }
}

// MARK: - Preview

struct ProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicture(service: StubProfilePictureService(), personId: SplitGroup.stub.members[0].id)
            .frame(width: 150, height: 150)
    }
}
