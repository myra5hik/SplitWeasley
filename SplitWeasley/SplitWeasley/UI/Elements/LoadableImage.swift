//
//  LoadableImage.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 09/02/23.
//

import SwiftUI

struct LoadableImage<E: Error>: View {
    let loadable: Loadable<UIImage, E>

    var body: some View {
        presentedView(loadable)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemGray2))
    }

    @ViewBuilder
    private func presentedView(_ loadable: Loadable<UIImage, E>) -> some View {
        switch loadable {
        case .loaded(let image):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case .loading:
            ProgressView().progressViewStyle(.circular)
        case .error(_):
            Image(systemName: "wifi.slash")
        }
    }
}

struct LoadableImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LoadableImage<Never>(loadable: .loaded(UIImage(named: "StubPic1")!))
                .frame(width: 100, height: 100)
                .clipped()
            LoadableImage<Never>(loadable: .loading)
                .frame(width: 100, height: 100)
                .clipped()
            LoadableImage<URLError>(loadable: .error(.init(.badURL)))
                .frame(width: 100, height: 100)
                .clipped()
        }
    }
}
