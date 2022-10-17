//
//  AdaptiveLinearComboBoxAdapter.swift
//  UIComboBox
//
//  Created by dev on 17/10/22.
//

import Foundation
import UIKit

/// A ``LinearComboBoxDataSource`` that delegates behaviour to the best data source class for the current platform.
public class AdaptiveLinearComboBoxDataSource<Item: Hashable>: NSObject, LinearComboBoxDataSource {
	
	public typealias Item = Item
 
	private let dataSource: ComboBoxDataSource
	
	private var compatDataSource: CompatLinearComboBoxDataSource<Item> {
		get {
			return dataSource as! CompatLinearComboBoxDataSource<Item>
		}
	}
	
	@available(iOS 13.0, *)
	private var diffableDataSource: DiffableLinearComboBoxDataSource<Item> {
		get {
				return dataSource as! DiffableLinearComboBoxDataSource<Item>
		}
	}
	
	/// An  `Array` that defines the contents provided by this data source.
	public var contents: [Item] {
		get {
			if #available(iOS 13.0, *) {
				return diffableDataSource.contents
			} else {
				return compatDataSource.contents
			}
		}
		set {
			if #available(iOS 13.0, *) {
				diffableDataSource.contents = newValue
			} else {
				compatDataSource.contents = newValue
			}
		}
	}
	
	public var selectedItem: Item? {
		get {
			if #available(iOS 13.0, *) {
				return diffableDataSource.selectedItem
			} else {
				return compatDataSource.selectedItem
			}
		}
		set {
			if #available(iOS 13.0, *) {
				diffableDataSource.selectedItem = newValue
			} else {
				compatDataSource.selectedItem = newValue
			}
		}
	}
	
	/// Initialises a new ``AdaptiveLinearComboBoxAdapter`` that uses the given closures to generate cells.
	///
	/// - Parameters:
	/// 	- selectionCellProvider: The closure used to generate cells to represent the currently selected item.
	/// 	- itemCellProvider: The closure used to generate cells representing selectable items.
	public init(
		selectionCellProvider: @escaping SelectionCellProvider<Item>,
		popupCellProvider: @escaping PopupCellProvider
	) {
		if #available(iOS 13.0, *) {
			dataSource = DiffableLinearComboBoxDataSource(selectionCellProvider: selectionCellProvider, popupCellProvider: popupCellProvider)
		} else {
			dataSource = CompatLinearComboBoxDataSource(selectionCellProvider: selectionCellProvider, popupCellProvider: popupCellProvider)
		}
	}
	
	
	public func installedIn(comboBox: ComboBoxView) {
		if #available(iOS 13.0, *) {
			diffableDataSource.installedIn(comboBox: comboBox)
		} else {
			compatDataSource.installedIn(comboBox: comboBox)
		}
	}
	
	public func installDataSource(inTableView tableView: UITableView) {
		if #available(iOS 13.0, *) {
			diffableDataSource.installDataSource(inTableView: tableView)
		} else {
			compatDataSource.installDataSource(inTableView: tableView)
		}
	}
	
	public func cellForDisplayingSelection(in comboBox: ComboBoxView) -> UITableViewCell? {
		if #available(iOS 13.0, *) {
			return diffableDataSource.cellForDisplayingSelection(in: comboBox)
		} else {
			return compatDataSource.cellForDisplayingSelection(in: comboBox)
		}
	}
	
	public func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView) {
		if #available(iOS 13.0, *) {
			diffableDataSource.didSelectCell(atIndex: index, for: comboBox)
		} else {
			compatDataSource.didSelectCell(atIndex: index, for: comboBox)
		}
	}
	
}
