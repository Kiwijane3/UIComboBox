//
//  ComboBoxDataSource.swift
//  NestedDropDown
//
//  Created by dev on 16/09/22.
//

import Foundation
import UIKit

/// A data source that provides the content displayed by a ``ComboBoxView``
@objc public protocol ComboBoxDataSource: UITableViewDelegate {
	
	/// A closure that generates a ``UITableViewCell`` to display the selected item in a ``ComboBoxView``
	///
	/// - Parameters:
	/// 	- comboBox: The ``ComboBoxView`` that the cell will be displayed in.
	/// 	- item: The currently selected item that the cell will represent.
	///
	///  - Returns: A configured ``UITableViewCell`` representing the selected item.
	typealias SelectionCellProvider<Item> = (_ comboBox: ComboBoxView, _ item: Item?) -> UITableViewCell?
	
	/// Called when the data source is added to a ``ComboBoxView``
	///
	/// - Parameter comboBox: The ``ComboBoxView`` that this does
	func installedIn(comboBox: ComboBoxView)
	
	/// Requests that this `ComboBoxDataSource` install its `UITableViewDataSource` in a `UITableView`.
	///
	/// - Parameter tableView: The `UITableView` to install the data source in.
	func installDataSource(inTableView tableView: UITableView)
	
	/// Asks the data source for a cell to display in the ``ComboBoxView`` itself to represent the currently selected item.
	///
	/// A recyclable cell can be obtained via ``ComboBoxView/dequeueReusableCell(withIdentifier:)``.
	/// To make a cell kind available, first register it with the ``ComboBoxView/register(_:forCellWithReuseIdentifier:inContext:)-7quws`` or
	/// ``ComboBoxView/register(_:forCellWithReuseIdentifier:inContext:)-5g4uo``.
	///
	/// - Parameter comboBox: The `comboBox` to provide a cell for.
	///
	/// - Returns: A `UITableViewCell` to be displayed in the `comboBox`.
	func cellForDisplayingSelection(in comboBox: ComboBoxView) -> UITableViewCell?
	
	/// Indicates that an item in the dropdown was selected.
	///
	/// - Parameters:
	/// 	- index: The `IndexPath` representing the position of the cell that was selected.
	///		- comboBox: The `comboBox` for which an item was selected.
	func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView)
	
}
