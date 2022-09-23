//
//  ReusableCell.swift
//  ComboBox
//
//  Created by dev on 23/09/22.
//

import Foundation
import UIKit


open class ReusableCell: UIView {
	
	@IBInspectable
	public var reuseIdentifier: String?
	
	open func prepareForReuse() {
		
	}
	
}
