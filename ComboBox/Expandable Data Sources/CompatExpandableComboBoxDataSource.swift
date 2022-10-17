//
//  CompatExpandableComboBoxDataSource.swift
//  ComboBox
//
//  Created by dev on 27/09/22.
//

import Foundation
import UIKit

/// An ``ExpandableComboBoxDataSource`` that manually updates the presented `UITableView`.
///
/// This data source class is available on all supported iOS versions, and can be used instead of ``DiffableExpandableComboBoxDataSource`` if compatibility with iOS versions prior to iOS 13 is required.
/// The main drawback is that this data source is not able to automatically animate changes to the dropdown elements if ``contents`` is updated while the dropdown is displayed.
public class CompatExpandableComboBoxDataSource<GroupIdentifier:Hashable, Item: Hashable>: NSObject, ExpandableComboBoxDataSource, UITableViewDataSource {
	
	public typealias GroupIdentifier = GroupIdentifier
	
	public typealias Item = Item
	
	private weak var tableView: UITableView?
	
	private weak var comboBox: ComboBoxView?
	
	public var contents: NestedList<GroupIdentifier, Item> = [] {
		didSet {
			guard contents != oldValue else {
				return
			}
		
			tableView?.reloadData()
			comboBox?.dropDownSizeChanged()
		}
	}
	
	public var selectedItem: Item?
	
	private var expandedSections: Set<GroupIdentifier> = []
	
	let selectionCellProvider: SelectionCellProvider<Item>
	
	let groupHeaderCellProvider: GroupHeaderCellProvider
	
	let itemCellProvider: ItemCellProvider
	
	/// Initialises a new `CompatExpandableComboBoxDataSource` that uses the given closures to generate cells.
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
		self.selectionCellProvider = selectionCellProvider
		self.groupHeaderCellProvider = groupHeaderCellProvider
		self.itemCellProvider = itemCellProvider
	}
	
	public func getExpansion(forGroupWithId groupId: GroupIdentifier) -> Bool {
		return expandedSections.contains(groupId)
	}
	
	public func setExpansion(forGroupWithId groupId: GroupIdentifier, to target: Bool) {
		
		guard getExpansion(forGroupWithId: groupId) != target,
				let sectionIndex = firstIndex(ofGroupWithId: groupId, in: contents),
				let itemCount = numberOfItems(inGroupAt: sectionIndex, in: contents) else {
			return
		}
		
		let indices = (1...itemCount).map { index in
			return IndexPath(row: index, section: sectionIndex)
		}
		
		if target == true {
			expandedSections.insert(groupId)
		} else {
			expandedSections.remove(groupId)
		}
		
		tableView?.beginUpdates()
		
		tableView?.reloadRows(at: [IndexPath(row: 0, section: sectionIndex)], with: .fade)
		
		if target == true {
			tableView?.insertRows(at: indices, with: .automatic)
		} else {
			tableView?.deleteRows(at: indices, with: .automatic)
		}
		
		tableView?.endUpdates()
		
	}
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return contents.count
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
		let item = contents[sectionIndex]
		
		switch item {
			case .item(_):
				return 1
			case .group(let groupId, let items):
				if getExpansion(forGroupWithId: groupId) {
					return 1 + items.count
				} else {
					return 1
				}
		}
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch contents[indexPath.section] {
			case .item(let item):
				return itemCellProvider(tableView, indexPath, item, nil)
			case .group(let groupId, let items):
				if indexPath.row == 0 {
					return groupHeaderCellProvider(tableView, indexPath, groupId, getExpansion(forGroupWithId: groupId))
				} else {
					return itemCellProvider(tableView, indexPath, items[indexPath.row - 1], groupId)
				}
		}
		
	}
	
	public func installedIn(comboBox: ComboBoxView) {
		self.comboBox = comboBox
	}
	
	public func installDataSource(inTableView tableView: UITableView) {
		self.tableView = tableView
		tableView.dataSource = self
	}
	
	public func cellForDisplayingSelection(in comboBox: ComboBoxView) -> UITableViewCell? {
		return selectionCellProvider(comboBox, selectedItem)
	}
	
	public func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView) {
		switch contents[index.section] {
			case .item(let item):
				selectedItem = item
				comboBox.selectionDidChange()
			case .group(let groupId, let items):
				if index.row == 0 {
					toggleExpansion(forGroupWithId: groupId)
					comboBox.dropDownSizeChanged()
				} else {
					selectedItem = items[index.row - 1]
					comboBox.selectionDidChange()
				}
		}
	}
	
}
