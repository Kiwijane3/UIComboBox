//
//  GroupHeaderCell.swift
//  NestedDropDown Test App
//
//  Created by dev on 21/09/22.
//

import Foundation
import UIKit

public class GroupHeaderCell: UITableViewCell {
	
	var expanded: Bool = false {
		didSet {
			indicator.image = expanded ? UIImage(named: "arrow.down") : UIImage(named: "arrow.forward")
		}
	}
	
	@IBOutlet weak var content: UILabel!
	
	@IBOutlet weak var indicator: UIImageView!
}
