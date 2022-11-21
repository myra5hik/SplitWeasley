//
//  SplitOptionsScreenView.swift
//  SplitWeasley
//
//  Created by Alexander Tokarev on 20/11/22.
//

import SwiftUI

struct SplitOptionsScreenView: View {
    private let splitGroup: SplitGroup
    private var sortedMembers: [Person] { splitGroup.members.sorted(by: { $0.fullName <= $1.fullName }) }
    @State private var selection = Set<Person.ID>()

    @State private var pickerSelection: Int = 0
    @State private var hintPlateHeader = "Split equally"
    @State private var hintPlateBody = "Select which people own an equal share:"

    init(splitGroup: SplitGroup) {
        self.splitGroup = splitGroup
    }

    var body: some View {
        VStack {
            VStack(spacing: 8) {
                splitStrategySegmentedControlView
                hintPlateView
            }
            .padding()
            splitGroupMembersListView
        }
    }
}

// MARK: - Components

private extension SplitOptionsScreenView {
    var splitStrategySegmentedControlView: some View {
        Picker(selection: $pickerSelection) {
            Image(systemName: "equal").tag(0)
            Text("1.23").tag(1)
            Image(systemName: "percent").tag(2)
            Image(systemName: "chart.pie.fill").tag(3)
            Image(systemName: "plus.forwardslash.minus").tag(4)
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
    }

    var hintPlateView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .foregroundColor(Color(uiColor: .tertiarySystemFill))
            VStack {
                Text(hintPlateHeader).font(.headline)
                Text(hintPlateBody).font(.subheadline)
            }
        }
        .frame(height: 60)
    }

    var splitGroupMembersListView: some View {
        List(sortedMembers, id: \.id) { member in
            ConfugurableListRowView(
                heading: member.fullName,
                subheading: selection.contains(member.id) ? "$3.92" : "not involved",
                leadingAccessory: { Circle().foregroundColor(.blue) },
                trailingAccessory: { if selection.contains(member.id) { Image(systemName: "checkmark") } },
                action: { if !selection.insert(member.id).inserted { selection.remove(member.id) } }
            )
        }
        .listStyle(.plain)
    }
}

// MARK: - Previews

struct SplitOptionsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplitOptionsScreenView(splitGroup: SplitGroup(id: UUID(), members: [
            Person(id: UUID(), firstName: "Alexander", lastName: nil),
            Person(id: UUID(), firstName: "Alena", lastName: nil),
            Person(id: UUID(), firstName: "Ilia", lastName: nil),
            Person(id: UUID(), firstName: "Oleg", lastName: nil)
        ]))
    }
}
