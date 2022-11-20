//
//  RoundButton.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 16/11/22.
//

import SwiftUI

struct RoundButton<FillStyle: ShapeStyle, Content: View>: View {
    private let bodyFill: FillStyle
    @ViewBuilder private let content: () -> (Content)
    private let action: (() -> Void)?

    init(
        bodyFill: FillStyle,
        action: (() -> Void)? = nil,
        _ content: @escaping () -> (Content)
    ) {
        self.bodyFill = bodyFill
        self.action = action
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)
            let shadowSize = diameter / 40
            let shadowColor = Color(UIColor.systemGray3)

            let buttonLabel = ZStack {
                Circle()
                    .stroke(lineWidth: diameter / 75)
                    .foregroundColor(Color(UIColor.systemGray4))
                Circle()
                    .fill(bodyFill)
                    .shadow(
                        color: shadowColor,
                        radius: shadowSize,
                        x: shadowSize - shadowSize / 2,
                        y: shadowSize - shadowSize / 2
                    )
                content()
                    .frame(width: diameter, height: diameter, alignment: .center)
                    .clipShape(Circle())
            }

            Button(action: action ?? { }, label: { buttonLabel }).buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

struct RoundButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundButton(bodyFill: Color(UIColor.systemBackground)) {
            Image(systemName: "dollarsign")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(0.5)
        }
        .padding()
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
