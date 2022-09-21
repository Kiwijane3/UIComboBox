//
//  NestedDropDownView.swift/Volumes/SFSymbols
//  NestedDropDown
//
//  Created by dev on 16/09/22.
//

import UIKit

public class ComboBoxView: UIView, UITableViewDelegate {
	
	public enum CellContext {
		case selection
		case dropdown
	}
	
	private var nibMap: [String: UINib] = [:]
	
	private let popup = ComboBoxPopupView()
	
	private var recycler: [String: UITableViewCell] = [:]
	
	@IBInspectable
	public var popupBackgroundColor: UIColor?
	
	public weak var dataSource: ComboBoxDataSource? = nil {
		didSet {
			dataSource?.installDataSource(inTableView: popup, forPopupOf: self)
			selectionDidChange()
		}
	}
	
	private var currentSelectionCell: UITableViewCell?
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		configure()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		configure()
	}
	
	public func configure() {
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
	}
	
	public func register(_ nib: UINib, forCellWithReuseIdentifier reuseIdentifier: String, inContext context: CellContext) {
		switch context {
			case .selection:
				nibMap[reuseIdentifier] = nib
			case .dropdown:
				popup.register(nib, forCellReuseIdentifier: reuseIdentifier)
		}
	}
	
	public func dequeueSelectionCell(withIdentifier identifier: String) -> UITableViewCell? {
		if let recycled = recycler[identifier] {
			recycler[identifier] = nil
			recycled.prepareForReuse()
			return recycled
		} else {
			return nibMap[identifier]?.instantiate(withOwner: nil).compactMap { object in
				return object as? UITableViewCell
			}.first
		}
	}
 
	public func selectionDidChange() {
		
		guard let dataSource = dataSource else {
			return
		}

		let newView = dataSource.cellForDisplayingSelection(in: self)
		
		newView?.prepareForReuse()
		
		if let newView = newView {
			
			addSubview(newView)
			
			newView.layer.opacity = 0
			
			newView.contentView.translatesAutoresizingMaskIntoConstraints = false
			newView.contentView.widthAnchor.constraint(equalTo: newView.widthAnchor).isActive = true
			newView.contentView.heightAnchor.constraint(equalTo: newView.heightAnchor).isActive = true
			newView.contentView.centerXAnchor.constraint(equalTo: newView.centerXAnchor).isActive = true
			newView.contentView.centerYAnchor.constraint(equalTo: newView.centerYAnchor).isActive = true
			
			newView.topAnchor.constraint(equalTo: topAnchor).isActive = true
			newView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			newView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
			bottomAnchor.constraint(equalTo: newView.bottomAnchor).isActive = true
			
			layoutIfNeeded()
			
		}
		
		UIView.animate(withDuration: 0.2) {
			newView?.layer.opacity = 1
			self.currentSelectionCell?.layer.opacity = 0
		} completion: { _ in
			self.currentSelectionCell?.removeFromSuperview()
			self.recycle(self.currentSelectionCell)
			self.currentSelectionCell = newView
		}
		
		popup.dismiss()
		
	}
	
	func recycle(_ cell: UITableViewCell?) {
		guard let cell = cell, let reuseIdentifier = cell.reuseIdentifier else {
			return
		}

		if recycler[reuseIdentifier] == nil {
			recycler[reuseIdentifier] = cell
		}
	}
	
	public func resizePopup() {
		popup.contentResized()
	}
	
	public func dismissPopup() {
		popup.dismiss()
	}
	
	@objc func onTap() {
		if popup.isHidden {
			popup.present(for: self)
		} else {
			popup.dismiss()
		}
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		dataSource?.didSelectCell(atIndex: indexPath, for: self)
	}
	
	
}
