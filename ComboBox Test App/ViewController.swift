//
//  ViewController.swift
//  NestedDropDown Test App
//
//  Created by dev on 19/09/22.
//

import UIKit
import ComboBox

class ViewController: UIViewController, ComboBoxViewDelegate {

	@IBOutlet weak var comboBox: ComboBoxView!
	
	let placeholderCellIdentifier = "PlaceholderCell"
	
	let selectionCellIdentifier = String(describing: SelectionCell.self)
	
	let groupHeaderCellIdentifier = String(describing: GroupHeaderCell.self)
	
	let itemCellIdentifier = String(describing: ItemCell.self)
	
	var dataSource: ExpandableComboBoxDataSource<String, String>!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		comboBox.register(UINib(nibName: "PlaceholderView", bundle: nil), forCellWithReuseIdentifier: placeholderCellIdentifier, inContext: .selection)
		comboBox.register(UINib(nibName: "SelectionCell", bundle: nil), forCellWithReuseIdentifier: selectionCellIdentifier, inContext: .selection)
		
		comboBox.register(UINib(nibName: "GroupHeaderCell", bundle: nil), forCellWithReuseIdentifier: groupHeaderCellIdentifier, inContext: .dropdown)
		comboBox.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier, inContext: .dropdown)
		
		dataSource = ExpandableComboBoxDataSource(
			selectionCellProvider: self.generateSelectionCell(_:forItem:),
			groupHeaderCellProvider: self.generateGroupHeaderCell(_:atIndex:forGroupWithId:isExpanded:),
			itemCellProvider: self.generateItemCell(_:atIndex:forItem:inGroupWithId:)
		)
		
		dataSource.contents = [
			.item(item: "Alpha"),
			.group(identifer: "Beta", items: ["Lambda", "Kappa"]),
			.group(identifer: "Gamma", items: ["Omega", "Delta", "Epsilon"])
		]
		
		comboBox.dataSource = dataSource
		comboBox.delegate = self
		
	}

	public func generateSelectionCell(_ comboBox: ComboBoxView, forItem item: String?) -> UITableViewCell? {
		
		if let item = item {
			let cell = comboBox.dequeueReusableCell(withIdentifier: selectionCellIdentifier) as! SelectionCell
			cell.content.text = item
			return cell
		} else {
			return comboBox.dequeueReusableCell(withIdentifier: placeholderCellIdentifier)
		}
		
	}
	
	public func generateGroupHeaderCell(_ tableView: UITableView, atIndex index: IndexPath, forGroupWithId groupId: String, isExpanded expanded: Bool) -> UITableViewCell? {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: groupHeaderCellIdentifier, for: index) as! GroupHeaderCell
		
		cell.content.text = groupId
		cell.expanded = expanded 
		
		return cell
	}
	
	public func generateItemCell(_ tableView: UITableView, atIndex index: IndexPath, forItem item: String, inGroupWithId groupId: String?) -> UITableViewCell? {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: index) as! ItemCell
		
		cell.content.text = item
		
		return cell
		
	}
	
	public func comboBoxViewDidChangeSelection() {
		print("ComboBox updated selection, is now: \(dataSource?.selectedItem ?? "nil")")
	}
	
	public func comboBoxView(_ comboBox: ComboBoxView, willShowPopup: UIView) {
		print("Will show popup")
	}
	
	public func comboBoxView(_ comboBox: ComboBoxView, didShowPopup: UIView) {
		print("Did show popup")
	}
	
	public func comboBoxView(_ comboBox: ComboBoxView, willDismissPopup: UIView) {
		print("Will dismiss popup")
	}
	
	public func comboBoxView(_ comboBox: ComboBoxView, didDismissPopup: UIView) {
		print("Did dismiss popup")
	}

}

