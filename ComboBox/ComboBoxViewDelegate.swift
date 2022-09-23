//
//  ComboBoxViewDelegate.swift
//  ComboBox
//
//  Created by dev on 23/09/22.
//

import Foundation
import UIKit

public protocol ComboBoxViewDelegate {
	
	func comboBoxViewDidChangeSelection()
	
	func comboBoxView(_ comboBox: ComboBoxView, willShowPopup: UIView)
	
	func comboBoxView(_ comboBox: ComboBoxView, didShowPopup: UIView)
	
	func comboBoxView(_ comboBox: ComboBoxView, willDismissPopup: UIView)
	
	func comboBoxView(_ comboBox: ComboBoxView, didDismissPopup: UIView)
	
}

extension ComboBoxViewDelegate {
	
	func comboBoxView(_ comboBox: ComboBoxView, willShowPopup: UIView) {}
	
	func comboBoxView(_ comboBox: ComboBoxView, didShowPopup: UIView) {}
	
	func comboBoxView(_ comboBox: ComboBoxView, willDismissPopup: UIView) {}
	
	func comboBoxView(_ comboBox: ComboBoxView, didDismissPopup: UIView) {}
	
}
