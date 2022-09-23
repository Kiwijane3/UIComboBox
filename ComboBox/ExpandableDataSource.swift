//
//  ExpandableDataSource.swift
//  NestedDropDown
//
//  Created by dev on 15/09/22.
//

import Foundation
import UIKit
import DiffableDataSources

public enum DropDownSection<GroupIdentifier: Hashable, Item: Hashable>: Hashable {
	case item(item: Item)
	case group(identifier: GroupIdentifier)
}

public enum DropDownItem<GroupIdentifier: Hashable, Item: Hashable>: Hashable {
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

public class ExpandableComboBoxDataSource<GroupIdentifier: Hashable, Item: Hashable>: NSObject, ComboBoxDataSource {
	
	public var contents: NestedList<GroupIdentifier, Item> = [] {
		didSet {
			recalculateContents()
		}
	}
	
	public var selectedItem: Item? = nil
	
	private var expandedSections: Set<GroupIdentifier> = []
	
	private var popupDataSource: TableViewDiffableDataSource<DropDownSection<GroupIdentifier, Item>, DropDownItem<GroupIdentifier, Item>>?
	
	public typealias GroupHeaderCellProvider = (UITableView, IndexPath, GroupIdentifier, Bool) -> UITableViewCell?
	
	public typealias ItemCellProvider = (UITableView, IndexPath, Item, GroupIdentifier?) -> UITableViewCell?
	
	private let selectionCellProvider: SelectionCellProvider<Item>
	
	private let groupHeaderCellProvider: GroupHeaderCellProvider
	
	private let itemCellProvider: ItemCellProvider
	
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
		
		var snapshot = DiffableDataSourceSnapshot<DropDownSection<GroupIdentifier, Item>, DropDownItem<GroupIdentifier, Item>>()
		
		contents.forEach { entry in
			let section = section(forEntry: entry)
			snapshot.appendSections([section])
			snapshot.appendItems(items(forEntry: entry), toSection: section)
		}
		
		popupDataSource.apply(snapshot, animatingDifferences: true, completion: completion)
		
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

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		guard let popupDataSource = popupDataSource else {
			return
		}
		
		let item = popupDataSource.itemIdentifier(for: indexPath)
		
		switch item {
			case .item(let item, _):
				selectedItem = item
			case .groupHeader(let groupId, let expanded):
				toggleExpansion(forGroup: groupId, isExpanded: expanded)
			default:
				break
		}
	}
	
	public func toggleExpansion(forGroup groupId: GroupIdentifier, isExpanded: Bool) {
		if isExpanded {
			expandedSections.remove(groupId)
		} else {
			expandedSections.insert(groupId)
		}

		recalculateContents()
	}
	
	public func installDataSource(inTableView tableView: UITableView, forPopupOf comboBox: ComboBoxView) {
		popupDataSource = TableViewDiffableDataSource(tableView: tableView, cellProvider: cellForPopup(in:at:item:))
		popupDataSource?.defaultRowAnimation = .fade
		recalculateContents()
	}
	
	public func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView) {
		
		guard let identifier = popupDataSource?.itemIdentifier(for: index) else {
			return
		}
		
		switch identifier {
			case .groupHeader(let groupId, let expanded):
				toggleExpansion(forGroup: groupId, isExpanded: expanded)
				comboBox.resizePopup()
			case .item(let item, _):
				comboBox.dismissPopup()
				
				if item != selectedItem {
					selectedItem = item
					comboBox.selectionDidChange()
				}
		}
		
	}
	
}
