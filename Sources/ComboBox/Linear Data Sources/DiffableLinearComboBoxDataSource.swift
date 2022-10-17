//
//  LinearComboBoxDataSource.swift
//  NestedDropDown
//
//  Created by dev on 16/09/22.
//

import Foundation
import UIKit

/// A ``ComboBoxDataSource`` that uses a `UITableViewDiffableDataSource` to manage the elements displayed in the drop-down.
///
/// Due to the use of a diffable data source, this class is only available on iOS 13 and later; If compatibility with earlier versions is needed,  use ``CompatLinearComboBoxDataSource``.
/// The primary advantage of this class is that it can animate changes to the elements displayed in the dropdown if ``contents`` is updated while the drop-down is displayed.
@available(iOS 13, *)
public class DiffableLinearComboBoxDataSource<Item: Hashable>: NSObject, LinearComboBoxDataSource {
	
	public typealias Item = Item
	
	public var contents: [Item] = [] {
		didSet {
			recalculateContents()
		}
	}
	
	public var selectedItem: Item? = nil
	
	private let selectionCellProvider: SelectionCellProvider<Item>
	
	private let popupCellProvider: PopupCellProvider

	private weak var comboBox: ComboBoxView?
	
	private var dropdownDataSource: UITableViewDiffableDataSource<Single, Item>?
	
	/// Initialises a new ``DiffableLinearComboBoxDataSource`` that uses the given closures to generate cells.
	///
	/// - Parameters:
	/// 	- selectionCellProvider: The closure used to generate cells to represent the currently selected item.
	/// 	- itemCellProvider: The closure used to generate cells representing selectable items.
	public init(selectionCellProvider: @escaping SelectionCellProvider<Item>, popupCellProvider: @escaping PopupCellProvider) {
		self.selectionCellProvider = selectionCellProvider
		self.popupCellProvider = popupCellProvider
		
		super.init()
	}
	
	public func cellForDisplayingSelection(in comboBox: ComboBoxView) -> UITableViewCell? {
		return selectionCellProvider(comboBox, selectedItem)
	}
	
	private func recalculateContents() {
		
		guard let popupDataSource = dropdownDataSource else {
			return
		}

		
		var snapshot = NSDiffableDataSourceSnapshot<Single, Item>()
		
		snapshot.appendSections([.only])
		
		snapshot.appendItems(contents, toSection: .only)
		
		popupDataSource.apply(snapshot, animatingDifferences: true)
		
		comboBox?.dropDownSizeChanged()
		
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		guard let popupDataSource = dropdownDataSource else {
			return
		}

		selectedItem = popupDataSource.itemIdentifier(for: indexPath)
	}
	
	public func installedIn(comboBox: ComboBoxView) {
		self.comboBox = comboBox
	}
	
	public func installDataSource(inTableView tableView: UITableView) {
		dropdownDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: popupCellProvider)
		
		recalculateContents()
	}
	
	public func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView) {
		
		comboBox.dismissDropdown()
		
		guard let item = dropdownDataSource?.itemIdentifier(for: index) else {
			return
		}
		
		if item != selectedItem {
			selectedItem = item
			comboBox.selectionDidChange()
		}

	}
	
}
