//
//  NestedList.swift
//  NestedDropDown
//
//  Created by dev on 15/09/22.
//

import Foundation

/// An enumeration representing the top-level entries in a ``NestedList``.
public enum NestedListEntry<GroupIdentifier, Item> {
	/// An entry representing an item that is not part of any group.
	case item(item: Item)
	/// An entry representing a group.
	///
	/// - Parameter identifier: A value that identifies the group.
	///	- Parameter items: The items contained in the group.
	case group(identifer: GroupIdentifier, items: [Item])
}

extension NestedListEntry: Equatable where GroupIdentifier: Equatable, Item: Equatable {
	
	public static func ==(left: Self, right: Self) -> Bool {
		switch (left, right) {
			case (.item(let leftItem), .item(let rightItem)):
				return leftItem == rightItem
			case (.group(let leftIdentifier, let leftItems), .group(let rightIdentifier, let rightItems)):
				return leftIdentifier == rightIdentifier && leftItems == rightItems
			default:
				return false
		}
	}
	
}

extension NestedListEntry: Hashable where GroupIdentifier: Hashable, Item: Hashable {
	
	public func hash(into hasher: inout Hasher) {
		switch self {
			case .item(let item):
				hasher.combine(item)
			case .group(let identifier, _):
				hasher.combine(identifier)
		}
	}
	
}

/// A list with a two-level hierarchy, where the elements can be contained within groups.
public typealias NestedList<GroupIdentifier, Item> = [NestedListEntry<GroupIdentifier, Item>]

/// Returns the index of the first group with the given identifier in the given nested list, or nil if the list does not contain any groups with that identifier.
func firstIndex<GroupIdentifier: Equatable, Item>(ofGroupWithId targetId: GroupIdentifier, in list: NestedList<GroupIdentifier, Item>) -> Int? {
	return list.firstIndex { entry in
		switch entry {
			case .item(_):
				return false
			case .group(let groupId, _):
				return groupId == targetId
		}
	}
}

/// Returns the number of items in the group at the given index in the given list, or nil if the entry at the index is a top-level item.
func numberOfItems<GroupIdentifier, Item>(inGroupAt groupIndex: Int, in list: NestedList<GroupIdentifier, Item>) -> Int? {
	switch list[groupIndex] {
		case .item:
			return nil
		case .group(_, let items):
			return items.count
	}
}

public extension Array {
	
	/// Generates a ``NestedList`` with the equivalent contents of this array.
	var asNestedList: NestedList<Single, Element> {
		return map { element in
			return .item(item: element)
		}
	}
	
}
