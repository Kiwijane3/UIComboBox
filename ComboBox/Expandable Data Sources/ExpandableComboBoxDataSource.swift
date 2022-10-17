//
//  ExpandableDataSource.swift
//  ComboBox
//
//  Created by dev on 27/09/22.
//

import Foundation
import UIKit

/// A ``ComboBoxDataSource`` that can display items in expandable groups.
public protocol ExpandableComboBoxDataSource: ComboBoxDataSource {
	
	/// A closure that configures and returns a cell to be displayed as a group header in the dropdown of a ``ComboBoxView``.
	///
	/// - Parameters:
	///		- tableView: The table view that the cell will be displayed in.
	///		- indexPath: The index path that specifies the location that the cell will be shown at.
	///		- groupIdentifier: The identifier of the group that the cell will represent.
	///		- isExpanded: Whether the group is currently expanded.
	///
	///	- Returns: A configured `UITableViewCell` representing the given group.
	typealias GroupHeaderCellProvider = (_ tableView: UITableView, _ indexPath: IndexPath, _ groupIdentifier: GroupIdentifier, _ isExpanded: Bool) -> UITableViewCell
	
	/// A closure that configures a cell to represent a selectable item in the dropdown of a ``ComboBoxView``
	///
	/// - Parameters:
	/// 	- tableView: The table view that the cell will be displayed in.
	/// 	- indexPath: The index path that specifies the location that the cell will be shown at.
	///		- item: The selectable item that the cell will represent.
	///		- groupIdentifier: The group that the item is part of, or nil if the item is not part of a group.
	///
	///	- Returns: A configured `UITableViewCell` representing the given item.
	typealias ItemCellProvider = (_ tableView: UITableView, _ indexPath: IndexPath, _ item: Item, _ groupIdentifier: GroupIdentifier?) -> UITableViewCell
	
	/// The type of the elements used to identify the groups displayed through this data source.
	associatedtype GroupIdentifier
	
	/// The type of the items that can be selected using this data source.
	associatedtype Item
	
	/// A ``NestedList`` that defines the content provided by this data source.
	var contents: NestedList<GroupIdentifier, Item> {
		get
		set
	}
	
	/// The currently selected item, or `nil` if no item has been selected.
	var selectedItem: Item? {
		get
		set
	}
	
	/// Returns whether the group with the given id is currently expanded.
	func getExpansion(forGroupWithId groupId: GroupIdentifier) -> Bool
	
	/// Sets whether the group with the given id is expanded.
	func setExpansion(forGroupWithId groupId: GroupIdentifier, to target: Bool)
	
}

public extension ExpandableComboBoxDataSource {
	
	/// Switches the expansion state of the group with the given id.
	func toggleExpansion(forGroupWithId groupId: GroupIdentifier) {
		setExpansion(forGroupWithId: groupId, to: !getExpansion(forGroupWithId: groupId))
	}
	
}

