//
//  ExpandableDataSource.swift
//  NestedDropDown
//
//  Created by dev on 15/09/22.
//

import Foundation
import UIKit

/// An ``ExpandableComboBoxDataSource`` that uses a `UITableViewDiffableDataSource` to manage the elements displayed in the drop-down.
///
/// Due to the use of a diffable data source, this class is only available on iOS 13 and later; If compatibility with earlier versions is needed,  use ``CompatExpandableComboBoxDataSource``.
/// The primary advantage of this class is that it can animate changes to the elements displayed in the dropdown if ``contents`` is updated while the drop-down is displayed.
@available(iOS 13, *)
public class DiffableExpandableComboBoxDataSource<GroupIdentifier: Hashable, Item: Hashable>: NSObject, ExpandableComboBoxDataSource, ComboBoxDataSource {
	
	public typealias GroupIdentifier = GroupIdentifier
	
	public typealias Item = Item
	
	public var contents: NestedList<GroupIdentifier, Item> = []
	
	public var selectedItem: Item? = nil
	
	private var expandedSections: Set<GroupIdentifier> = []
	
	private var popupDataSource: UITableViewDiffableDataSource<DropDownSection<GroupIdentifier, Item>, DropDownItem<GroupIdentifier, Item>>?
	
	private weak var comboBox: ComboBoxView?
	
	public typealias GroupHeaderCellProvider = (UITableView, IndexPath, GroupIdentifier, Bool) -> UITableViewCell?
	
	public typealias ItemCellProvider = (UITableView, IndexPath, Item, GroupIdentifier?) -> UITableViewCell?
	
	private let selectionCellProvider: SelectionCellProvider<Item>
	
	private let groupHeaderCellProvider: GroupHeaderCellProvider
	
	private let itemCellProvider: ItemCellProvider
	
	/// Initialises a new `DiffableExpandableComboBoxDataSource` that uses the given closures to generate cells.
	///
	/// - Parameters:
	/// 	- selectionCellProvider: The closure used to generate cells to represent the currently selected item.
	///		- groupHeaderCellProvider: The closure used to generate cells which act as group headers.
	///		- itemCellProvider: The closure used to generate cells representing selectable items.
	public init(
		 selectionCellProvider: @escaping SelectionCellProvider<Item>,
		 groupHeaderCellProvider: @escaping GroupHeaderCellProvider,
		 itemCellProvider: @escaping ItemCellProvider) {
		
		self.selectionCellProvider = selectionCellProvider
		self.groupHeaderCellProvider = groupHeaderCellProvider
		self.itemCellProvider = itemCellProvider
		
		super.init()
	}
	
	public func cellForDisplayingSelection(in comboBox: ComboBoxView) -> UITableViewCell? {
		return selectionCellProvider(comboBox, selectedItem)
	}
	
	func cellForPopup(in tableView: UITableView, at index: IndexPath, item: DropDownItem<GroupIdentifier, Item>) -> UITableViewCell? {
		switch item {
			case .groupHeader(let groupIdentifier, let expanded):
				return groupHeaderCellProvider(tableView, index, groupIdentifier, expanded)
			case .item(let item, let groupIdentifier):
				return itemCellProvider(tableView, index, item, groupIdentifier)
		}
	}
	
	private func recalculateContents(completion: (() -> Void)? = nil) {
		
		guard let popupDataSource = popupDataSource else {
			return
		}
		
		var snapshot = NSDiffableDataSourceSnapshot<DropDownSection<GroupIdentifier, Item>, DropDownItem<GroupIdentifier, Item>>()
		
		contents.forEach { entry in
			let section = section(forEntry: entry)
			snapshot.appendSections([section])
			snapshot.appendItems(items(forEntry: entry), toSection: section)
		}
		
		popupDataSource.apply(snapshot, animatingDifferences: true, completion: completion)
		comboBox?.dropDownSizeChanged()
		
	}
	
	private func section(forEntry entry: NestedListEntry<GroupIdentifier, Item>) -> DropDownSection<GroupIdentifier, Item> {
		switch entry {
			case .item(let item):
				return .item(item: item)
			case .group(let identifer, _):
				return .group(identifier: identifer)
		}
	}
	
	private func items(forEntry entry: NestedListEntry<GroupIdentifier, Item>) -> [DropDownItem<GroupIdentifier, Item>] {
		switch entry {
			case .item(let item):
				return [.item(item: item, group: nil)]
			case .group(let groupId, let items):
				return [.groupHeader(identifier: groupId, expanded: expandedSections.contains(groupId))] + subItems(for: items, in: groupId)
		}
	}
	
	private func subItems(for items: [Item], in group: GroupIdentifier) -> [DropDownItem<GroupIdentifier, Item>] {
		guard expandedSections.contains(group) else {
			return []
		}
		
		return items.map { item in
				.item(item: item, group: group)
		}
	}
	
	public func getExpansion(forGroupWithId groupId: GroupIdentifier) -> Bool {
		return expandedSections.contains(groupId)
	}
	
	public func setExpansion(forGroupWithId groupId: GroupIdentifier, to target: Bool) {
		
		guard getExpansion(forGroupWithId: groupId) != target else {
			return
		}
		
		if target == true {
			expandedSections.insert(groupId)
		} else {
			expandedSections.remove(groupId)
		}
		
		recalculateContents()
		
	}
	
	public func installedIn(comboBox: ComboBoxView) {
		self.comboBox = comboBox
	}
	
	public func installDataSource(inTableView tableView: UITableView) {
		
		popupDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: cellForPopup(in:at:item:))
		popupDataSource?.defaultRowAnimation = .fade
		
		recalculateContents()
		
	}
	
	public func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView) {
		
		guard let identifier = popupDataSource?.itemIdentifier(for: index) else {
			return
		}
		
		switch identifier {
			case .groupHeader(let groupId, _):
				toggleExpansion(forGroupWithId: groupId)
			case .item(let item, _):
				if item != selectedItem {
					selectedItem = item
					comboBox.selectionDidChange()
				} else {
					comboBox.dismissDropdown()
				}
		}
		
	}
	
}
