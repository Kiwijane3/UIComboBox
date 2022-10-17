//
//  ItemCell.swift
//  NestedDropDown Test App
//
//  Created by dev on 21/09/22.
//

import Foundation
import UIKit

public class ItemCell: UITableViewCell {
	
	@IBOutlet weak var content: UILabel!
	
	@IBOutlet weak var frameView: UIView!
	
	@IBOutlet var topMarginConstraint: NSLayoutConstraint!
	
	public override func awakeFromNib() {
		frameView.layer.cornerRadius = 8
		frameView.clipsToBounds = true
	}
	
}
