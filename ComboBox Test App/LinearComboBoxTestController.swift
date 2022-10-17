//
//  LinearComboBoxTestController.swift
//  UIComboBox
//
//  Created by dev on 17/10/22.
//

import Foundation
import UIKit
import UIComboBox

public class LinearComboBoxTestController: UIViewController, ComboBoxView.Delegate {
	
	@IBOutlet weak var comboBox: ComboBoxView!
	
	let placeholderCellIdentifier = "PlaceholderCell"
	
	let selectionCellIdentifier = String(describing: SelectionCell.self)
	
	let itemCellIdentifier = String(describing: ItemCell.self)
	
	var contents = ["Alpha", "Beta", "Gamma", "Kappa", "Epsilon", "Omega"]
	
	var dataSource: AdaptiveLinearComboBoxDataSource<String>?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		comboBox.register(UINib(nibName: "PlaceholderView", bundle: nil), forCellWithReuseIdentifier: placeholderCellIdentifier, inContext: .selection)
		comboBox.register(UINib(nibName: "SelectionCell", bundle: nil), forCellWithReuseIdentifier: selectionCellIdentifier, inContext: .selection)
		
		comboBox.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: itemCellIdentifier, inContext: .dropdown)
		
		dataSource = AdaptiveLinearComboBoxDataSource(
			selectionCellProvider: self.generateSelectionCell(_:forItem:),
			popupCellProvider: self.generateItemCell(_:atIndex:forItem:)
		)
		
		dataSource?.contents = contents
		
		comboBox.dataSource = dataSource
		comboBox.delegate = self
		
	}

	public func generateSelectionCell(_ comboBox: ComboBoxView, forItem item: String?) -> UITableViewCell {
		
		if let item = item {
			let cell = comboBox.dequeueReusableCell(withIdentifier: selectionCellIdentifier) as! SelectionCell
			cell.content.text = item
			return cell
		} else {
			return comboBox.dequeueReusableCell(withIdentifier: placeholderCellIdentifier)!
		}
		
	}
	
	public func generateItemCell(_ tableView: UITableView, atIndex index: IndexPath, forItem item: String) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: index) as! ItemCell
		
		cell.content.text = item
		
		cell.topMarginConstraint.isActive = index.section == 0 && index.row == 0
		
		return cell
		
	}
	
	public func comboBoxViewDidChangeSelection(_ comboBox: ComboBoxView) {
		print("ComboBox updated selection, is now: \(dataSource?.selectedItem ?? "nil")")
	}
	
	public func comboBoxView(_ comboBox: ComboBoxView, willShowDropdown: UIView) {
		print("Will show popup")
		
		dataSource?.contents = contents
	}
	
	public func comboBoxView(_ comboBox: ComboBoxView, didShowDropdown: UIView) {
		print("Did show popup")
	}
	
	public func comboBoxView(_ comboBox: ComboBoxView, willDismissDropdown: UIView) {
		print("Will dismiss popup")
	}
	
	public func comboBoxView(_ comboBox: ComboBoxView, didDismissDropdown: UIView) {
		print("Did dismiss popup")
	}

}
