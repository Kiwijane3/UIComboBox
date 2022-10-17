//
//  AdaptiveExpandableComboBoxDataSource.swift
//  UIComboBox
//
//  Created by dev on 30/09/22.
//

import Foundation
import UIKit

/// A n ``ExpandableComboBoxDataSourceComboBoxDataSource`` that delegates behaviour to the best data source class for the current platform.
public class AdaptiveExpandableComboBoxDataSource<GroupIdentifier: Hashable, Item: Hashable>: NSObject, ExpandableComboBoxDataSource {
	
	public typealias GroupIdentifier = GroupIdentifier
	public typealias Item = Item
	
	let dataSource: ComboBoxDataSource
	
	var compatDataSource: CompatExpandableComboBoxDataSource<GroupIdentifier, Item>! {
		get {
			return dataSource as? CompatExpandableComboBoxDataSource<GroupIdentifier, Item>
		}
	}
	
	@available(iOS 13, *)
	var diffableDataSource: DiffableExpandableComboBoxDataSource<GroupIdentifier, Item> {
		get {
			return dataSource as! DiffableExpandableComboBoxDataSource<GroupIdentifier, Item>
		}
	}
	
	/// Initialises a new `AdaptiveExpandableComboBoxDataSource` that uses the given closures to generate cells.
	///
	/// - Parameters:
	/// 	- selectionCellProvider: The closure used to generate cells to represent the currently selected item.
	///		- groupHeaderCellProvider: The closure used to generate cells which act as group headers.
	///		- itemCellProvider: The closure used to generate cells representing selectable items.
	public init(
		selectionCellProvider: @escaping SelectionCellProvider<Item>,
		groupHeaderCellProvider: @escaping GroupHeaderCellProvider,
		itemCellProvider: @escaping ItemCellProvider
	) {
		if #available(iOS 13, *) {
			dataSource = DiffableExpandableComboBoxDataSource(
				selectionCellProvider: selectionCellProvider,
				groupHeaderCellProvider: groupHeaderCellProvider,
				itemCellProvider: itemCellProvider
			)
		} else {
			dataSource = CompatExpandableComboBoxDataSource(
				selectionCellProvider: selectionCellProvider,
				groupHeaderCellProvider: groupHeaderCellProvider,
				itemCellProvider: itemCellProvider
			)
		}
	}
	
	public var contents: NestedList<GroupIdentifier, Item> {
		get {
			if #available(iOS 13, *) {
				return diffableDataSource.contents
			} else {
				return compatDataSource.contents
			}
		}
		set {
			if #available(iOS 13, *) {
				diffableDataSource.contents = newValue
			} else {
				compatDataSource.contents = newValue
			}
		}
	}
	
	public var selectedItem: Item? {
		get {
			if #available(iOS 13, *) {
				return diffableDataSource.selectedItem
			} else {
				return compatDataSource.selectedItem
			}
		}
		set {
			if #available(iOS 13, *) {
				diffableDataSource.selectedItem = newValue
			} else {
				compatDataSource.selectedItem = newValue
			}
		}
	}
	
	public func getExpansion(forGroupWithId groupId: GroupIdentifier) -> Bool {
		if #available(iOS 13, *) {
			return diffableDataSource.getExpansion(forGroupWithId: groupId)
		} else {
			return compatDataSource.getExpansion(forGroupWithId: groupId)
		}
	}
	
	public func setExpansion(forGroupWithId groupId: GroupIdentifier, to target: Bool) {
		if #available(iOS 13, *) {
			diffableDataSource.setExpansion(forGroupWithId: groupId, to: target)
		} else {
			compatDataSource.setExpansion(forGroupWithId: groupId, to: target)
		}
	}
	
	public func installedIn(comboBox: ComboBoxView) {
		if #available(iOS 13, *) {
			diffableDataSource.installedIn(comboBox: comboBox)
		} else {
			compatDataSource.installedIn(comboBox: comboBox)
		}
	}
	
	public func installDataSource(inTableView tableView: UITableView) {
		if #available(iOS 13, *) {
			diffableDataSource.installDataSource(inTableView: tableView)
		} else {
			compatDataSource.installDataSource(inTableView: tableView)
		}
	}
	
	public func cellForDisplayingSelection(in comboBox: ComboBoxView) -> UITableViewCell? {
		if #available(iOS 13, *) {
			return diffableDataSource.cellForDisplayingSelection(in: comboBox)
		} else {
			return compatDataSource.cellForDisplayingSelection(in: comboBox)
		}
	}
	
	public func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView) {
		if #available(iOS 13, *) {
			diffableDataSource.didSelectCell(atIndex: index, for: comboBox)
		} else {
			compatDataSource.didSelectCell(atIndex: index, for: comboBox)
		}
	}
	
}
