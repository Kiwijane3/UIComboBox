//
//  NestedList.swift
//  NestedDropDown
//
//  Created by dev on 15/09/22.
//

import Foundation

public enum NestedListEntry<GroupIdentifier: Hashable, Item: Hashable> {
	case item(item: Item)
	case group(identifer: GroupIdentifier, items: [Item])
}

public typealias NestedList<GroupIdentifier: Hashable, Item: Hashable> = [NestedListEntry<GroupIdentifier, Item>]
