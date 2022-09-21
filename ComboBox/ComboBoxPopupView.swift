//
//  ComboBoxPopupView.swift
//  NestedDropDown
//
//  Created by dev on 16/09/22.
//

import Foundation
import UIKit

class ComboBoxPopupView: UITableView, UIGestureRecognizerDelegate {
	
	var dismissGestureRecogniser: UITapGestureRecognizer!
	
	override var intrinsicContentSize: CGSize {
		get {
			return contentSize
		}
	}
	
	public init() {
		super.init(frame: .zero, style: .plain)
		configure()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		configure()
	}
	
	func configure() {
		layer.cornerRadius = 4
		clipsToBounds = true
		
		separatorStyle = .none
		
		dismissGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismiss))
		dismissGestureRecogniser.delegate = self
		dismissGestureRecogniser.cancelsTouchesInView = false
	}
	
	func present(for comboBox: ComboBoxView) {
		
		guard let superview = comboBox.superview, isHidden else {
			return
		}
		
		self.delegate = comboBox
		
		self.translatesAutoresizingMaskIntoConstraints = false
		
		if self.superview != superview {
			
			if let currentSuperview = self.superview {
				currentSuperview.removeGestureRecognizer(dismissGestureRecogniser)
				removeFromSuperview()
			}
			
			superview.addSubview(self)
			superview.addGestureRecognizer(dismissGestureRecogniser)
			
			topAnchor.constraint(equalTo: comboBox.bottomAnchor).isActive = true
			leftAnchor.constraint(equalTo: comboBox.leftAnchor).isActive = true
			widthAnchor.constraint(equalTo: comboBox.widthAnchor).isActive = true
			
			bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor, constant: -8).isActive = true
			
			layoutIfNeeded()
			
		}
		
		backgroundColor = comboBox.popupBackgroundColor
		separatorStyle = .none
		
		self.layer.opacity = 0
		self.isHidden = false
		
		let initialFrame = frame
		frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: 0))
		
		UIView.animate(withDuration: 0.2) {
			self.layer.opacity = 1
			self.frame = initialFrame
		}

	}
	
	@objc func dismiss() {
		
		guard !isHidden else {
			return
		}
		
		UIView.animate(withDuration: 0.2) {
			self.layer.opacity = 0
		} completion: { [weak self] completed in
			self?.isHidden = true
		}

	}
	
	func contentResized() {
		
		let initialHeight = frame.height
		
		invalidateIntrinsicContentSize()
		layoutIfNeeded()
		
		let targetHeight = frame.height
		
		frame = CGRect(origin: frame.origin, size: .init(width: frame.width, height: initialHeight))
		
		UIView.animate(withDuration: 0.2) {
			self.frame = CGRect(origin: self.frame.origin, size: .init(width: self.frame.width, height: targetHeight))
		}
		
	}
	
	override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard gestureRecognizer == dismissGestureRecogniser else {
			return true
		}
		
		return !isHidden && !bounds.contains(gestureRecognizer.location(in: self))
	}
	
}
