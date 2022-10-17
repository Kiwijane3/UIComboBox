//
//  LinearComboBoxDataSource.swift
//  UIComboBox
//
//  Created by dev on 17/10/22.
//

import Foundation
import UIKit

/// A ``ComboBoxDataSource`` that displays a non-hierarchical list of selectable items.
public protocol LinearComboBoxDataSource: ComboBoxDataSource {
	
	/// The type of the items that can be selected using this data source.
	associatedtype Item: Hashable
	
	/// An ``Array`` that defines the content provided by this data source.
	var contents: [Item] {
		get
		set
	}
	
	/// The currently selected item, or `nil` if no item has been selected.
	var selectedItem: Item? {
		get
		set
	}
	
	/// A closure that configures a cell to represent a selectable item in the dropdown of a ``ComboBoxView``
	///
	/// - Parameters:
	/// 	- tableView: The table view that the cell will be displayed in.
	/// 	- indexPath: The index path that specifies the location that the cell will be shown at.
	///		- item: The selectable item that the cell will represent.
	///
	///	- Returns: A configured `UITableViewCell` representing the given item.
	typealias PopupCellProvider = (_ tableView: UITableView, _ indexPath: IndexPath, _ item: Item) -> UITableViewCell
	
}
