//
//  CompatLinearComboBoxDataSource.swift
//  UIComboBox
//
//  Created by dev on 17/10/22.
//

import Foundation
import UIKit


/// A basic ``ComboBoxDataSource`` that displays a non-hierarchical list of choices.
///
/// This data source class is available on all supported iOS versions, and can be used instead of ``DiffableLinearComboBoxDataSource`` if compatibility with iOS versions prior to iOS 13 is required.
/// The main drawback is that this data source is not able to automatically animate changes to the dropdown elements if ``contents`` is updated while the dropdown is displayed.
public class CompatLinearComboBoxDataSource<Item: Hashable>: NSObject, LinearComboBoxDataSource, UITableViewDataSource {
	
	public typealias Item = Item
	
	public var contents: [Item] = [] {
		didSet {
			guard contents != oldValue else {
				return
			}
			
			tableView?.reloadData()
			comboBox?.dropDownSizeChanged()
		}
	}
	
	public var selectedItem: Item? = nil
	
	public typealias PopupCellProvider = (UITableView, IndexPath, Item) -> UITableViewCell
	
	private let selectionCellProvider: SelectionCellProvider<Item>
	
	private let popupCellProvider: PopupCellProvider
	
	private weak var comboBox: ComboBoxView?
	
	private weak var tableView: UITableView?
	
	/// Initialises a new ``CompatLinearComboBoxDataSource`` that uses the given closures to generate cells.
	///
	/// - Parameters:
	/// 	- selectionCellProvider: The closure used to generate cells to represent the currently selected item.
	/// 	- itemCellProvider: The closure used to generate cells representing selectable items.
	public init(selectionCellProvider: @escaping SelectionCellProvider<Item>, popupCellProvider: @escaping PopupCellProvider) {
		self.selectionCellProvider = selectionCellProvider
		self.popupCellProvider = popupCellProvider
		
		super.init()
	}
	
	public func installedIn(comboBox: ComboBoxView) {
		self.comboBox = comboBox
	}
	
	public func installDataSource(inTableView tableView: UITableView) {
		tableView.dataSource = self
	}
	
	public func cellForDisplayingSelection(in comboBox: ComboBoxView) -> UITableViewCell? {
		return selectionCellProvider(comboBox, selectedItem)
	}
	
	public func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView) {
		selectedItem = contents[index.row]
		comboBox.selectionDidChange()
	}
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return contents.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return popupCellProvider(tableView, indexPath, contents[indexPath.row])
	}
	
}
