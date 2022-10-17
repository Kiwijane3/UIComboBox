//
//  ComboBoxViewDelegate.swift
//  ComboBox
//
//  Created by dev on 23/09/22.
//

import Foundation
import UIKit

/// A protocol for an entity that receives events from a ``ComboBoxView``.
public protocol ComboBoxViewDelegate {
	
	/// Called when the selected item for the combo box changes.
	/// - Parameter comboBox: The combo box for which the selection has changed.
	func comboBoxViewDidChangeSelection(_ comboBox: ComboBoxView)
	
	/// Called when the comboBox is about to show its dropdown.
	///
	/// - Parameters:
	/// 	- comboBox: The combo box that will show its dropdown.
	///		- dropdown: The `UIView` that is being displayed as a dropdown.
	func comboBoxView(_ comboBox: ComboBoxView, willShowDropdown dropdown: UIView)
	
	/// Called when the combo box has shown its dropdown.
	///
	///- Parameters:
	///		- comboBox: The combo box that has displayed its dropdown.
	///		- dropdown: The `UIView` that has been displayed as a dropdown.
	func comboBoxView(_ comboBox: ComboBoxView, didShowDropdown dropdown: UIView)
	
	/// Called when the combo box is about to hide its dropdown.
	///
	/// - Parameters:
	/// 	- comboBox: The combo box that will hide its dropdown.
	/// 	- dropdown: The `UIView` that is being displayed as a dropdown and will be hidden.
	func comboBoxView(_ comboBox: ComboBoxView, willDismissDropdown dropdown: UIView)
	
	/// Called when the combo box has hidden its dropdown.
	///
	///  - Parameters:
	///  	- comboBox: The combo box that has hidden its dropdown.
	///  	- dropdown: The `UIView` that was displayed as a dropdown and has been hidden.
	func comboBoxView(_ comboBox: ComboBoxView, didDismissDropdown dropdown: UIView)
	
}

public extension ComboBoxViewDelegate {
	
	func comboBoxView(_ comboBox: ComboBoxView, willShowDropdown: UIView) {}
	
	func comboBoxView(_ comboBox: ComboBoxView, didShowDropdown: UIView) {}
	
	func comboBoxView(_ comboBox: ComboBoxView, willDismissDropdown: UIView) {}
	
	func comboBoxView(_ comboBox: ComboBoxView, didDismissDropdown: UIView) {}
	
}
