//
//  ComboBoxDataSource.swift
//  NestedDropDown
//
//  Created by dev on 16/09/22.
//

import Foundation
import UIKit

public protocol ComboBoxDataSource: UITableViewDelegate {
	
	typealias SelectionCellProvider<Item> = (ComboBoxView, Item?) -> UITableViewCell?
	
	func installDataSource(inTableView tableView: UITableView, forPopupOf comboBox: ComboBoxView)
	
	func cellForDisplayingSelection(in comboBox: ComboBoxView) -> UITableViewCell?
	
	func didSelectCell(atIndex index: IndexPath, for comboBox: ComboBoxView)
	
}
