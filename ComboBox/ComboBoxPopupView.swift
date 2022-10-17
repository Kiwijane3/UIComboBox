//
//  ComboBoxPopupView.swift
//  NestedDropDown
//
//  Created by dev on 16/09/22.
//

import Foundation
import UIKit

internal class ComboBoxPopupView: UITableView, UIGestureRecognizerDelegate {
	
	weak var comboBox: ComboBoxView?
	
	override var contentSize: CGSize {
		didSet {
			invalidateIntrinsicContentSize()
		}
	}
	
	override var intrinsicContentSize: CGSize {
		get {
			return .init(width: UIView.noIntrinsicMetric, height: contentSize.height)
		}
	}
	
}
