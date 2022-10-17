//
//  ExpandableDropDownEntry.swift
//  ComboBox
//
//  Created by dev on 29/09/22.
//

import Foundation

enum DropDownSection<GroupIdentifier: Hashable, Item: Hashable>: Hashable {
	case item(item: Item)
	case group(identifier: GroupIdentifier)
}

enum DropDownItem<GroupIdentifier: Hashable, Item: Hashable>: Hashable {
	case groupHeader(identifier: GroupIdentifier, expanded: Bool)
	case item(item: Item, group: GroupIdentifier?)
}

extension DropDownItem {
	
	public func hash(into hasher: inout Hasher) {
		switch self {
			case .groupHeader(let identifier, _):
				hasher.combine(identifier)
			case .item(let item, let group):
				hasher.combine(item)
				hasher.combine(group)
		}
	}
	
	public static func ==(a: DropDownItem, b: DropDownItem) -> Bool {
		switch (a, b) {
			case (.groupHeader(let identifierA, let expandedA), .groupHeader(let identifierB, let expandedB)):
				return identifierA == identifierB && expandedA == expandedB
			case (.item(let itemA, let groupA), .item(let itemB, let groupB)):
				return itemA == itemB && groupA == groupB
			default:
				return false
		}
	}
	
}
