//
//  LinearComboBoxDataSource.swift
//  NestedDropDown
//
//  Created by dev on 16/09/22.
//

import Foundation
import UIKit
import DiffableDataSources

public class LinearComboBoxDataSource<Item: Hashable>: NSObject, ComboBoxDataSource {
	
	public var contents: [Item] = [] {
		didSet {
			recalculateContents()
		}
	}
	
	public var selectedItem: Item? = nil
	
	public typealias PopupCellProvider = (UITableView, IndexPath, Item) -> UITableViewCell?
	
	private let selectionCellProvider: SelectionCellProvider<Item>
	
	private let popupCellProvider: PopupCellProvider

	private var popupDataSource: TableViewDiffableDataSource<Single, Item>?
	
	public init(selectionCellProvider: @escaping SelectionCellProvider<Item>, popupCellProvider: @escaping PopupCellProvider) {
		self.selectionCellProvider = selectionCellProvider
		self.popupCellProvider = popupCellProvider
		
		super.init()
	}
	
	public func cellForDisplayingSelection(in comboBox: ComboBoxView) -> UITableViewCell? {
		return selectionCellProvider(comboBox, selectedItem)
	}
	
	private func recalculateContents() {
		
		guard let popupDataSource = popupDataSource else {
			return
		}

		
		var snapshot = DiffableDataSourceSnapshot<Single, Item>()
		
		snapshot.appendSections([.only])
		
		snapshot.appendItems(contents, toSection: .only)
		
		popupDataSource.apply(snapshot, animatingDifferences: true)
		
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		guard let popupDataSource = popupDataSource else {
			return
		}

		selectedItem = popupDataSource.itemIdentifier(for: indexPath)
	}
	
	public func installDataSource(inTableView tableView: UITableView, forPopupOf comboBox: ComboBoxView) {
		popupDataSource = TableViewDiffableDataSource(tableView: tableView, cellProvider: popupCellProvider)
		
		recalculateContents()
	}
	
	public func shouldDismissPopup(forSelectionAtIndex index: IndexPath) -> Bool {
		return true
	}
	
	public func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView) {
		
		comboBox.dismissPopup()
		
		guard let item = popupDataSource?.itemIdentifier(for: index) else {
			return
		}
		
		if item != selectedItem {
			selectedItem = item
			comboBox.selectionDidChange()
		}

	}
	
}
