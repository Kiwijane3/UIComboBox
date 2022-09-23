//
//  NestedDropDownView.swift/Volumes/SFSymbols
//  NestedDropDown
//
//  Created by dev on 16/09/22.
//

import UIKit

public class ComboBoxView: UIView, UITableViewDelegate, UIGestureRecognizerDelegate {
	
	public enum CellContext {
		case selection
		case dropdown
	}
	
	private var nibMap: [String: UINib] = [:]
	
	private lazy var popup = ComboBoxPopupView()
	
	private var recycler: [String: UITableViewCell] = [:]
	
	public var delegate: ComboBoxViewDelegate?
	
	@IBInspectable
	public var popupBackgroundColor: UIColor?

	@IBInspectable
	public var popupSeparatorStyle: UITableViewCell.SeparatorStyle = .none
	
	@IBInspectable
	public var popupCornerRadius: CGFloat = 8
	
	public weak var dataSource: ComboBoxDataSource? = nil {
		didSet {
			dataSource?.installDataSource(inTableView: popup, forPopupOf: self)
			selectionDidChange()
		}
	}
	
	private var currentSelectionCell: UITableViewCell?
	
	private var isPresentingPopup: Bool = false {
		didSet {
			popup.isHidden = !isPresentingPopup
		}
	}
	
	private var dismissGestureRecogniser: UITapGestureRecognizer!
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		configure()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		configure()
	}
	
	public func configure() {
		
		dismissGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
		dismissGestureRecogniser.delegate = self
		
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
	
	public func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
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
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		dataSource?.didSelectCell(atIndex: indexPath, for: self)
	}
 
	public func selectionDidChange() {
		
		delegate?.comboBoxViewDidChangeSelection()
		
		guard let dataSource = dataSource else {
			return
		}

		let newView = dataSource.cellForDisplayingSelection(in: self)
		
		if let newView = newView {
			
			addSubview(newView)
			
			newView.layer.opacity = 0
			newView.contentView.translatesAutoresizingMaskIntoConstraints = false
			
			newView.contentView.topAnchor.constraint(equalTo: newView.topAnchor).isActive = true
			newView.contentView.leftAnchor.constraint(equalTo: newView.leftAnchor).isActive = true
			newView.contentView.rightAnchor.constraint(equalTo: newView.rightAnchor).isActive = true
			newView.contentView.bottomAnchor.constraint(equalTo: newView.bottomAnchor).isActive = true
			
			newView.topAnchor.constraint(equalTo: topAnchor).isActive = true
			newView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			newView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
			newView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
			
			layoutIfNeeded()
			
		}
		
		UIView.animate(withDuration: 0.2) {
			newView?.layer.opacity = 1
			self.currentSelectionCell?.layer.opacity = 0
		} completion: { [weak self] _ in
			guard let self = self else { return }
				
			self.currentSelectionCell?.removeFromSuperview()
			self.recycle(self.currentSelectionCell)
			self.currentSelectionCell = newView
		}
		
		dismissPopup()
		
	}
	
	func recycle(_ cell: UITableViewCell?) {
		guard let cell = cell, let reuseIdentifier = cell.reuseIdentifier else {
			return
		}

		if recycler[reuseIdentifier] == nil {
			recycler[reuseIdentifier] = cell
		}
	}
	
	@objc func onTap() {
		guard !isPresentingPopup else {return}
		
		presentPopup()
	}
	
	public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard gestureRecognizer == dismissGestureRecogniser else {
			return true
		}
		
		return isPresentingPopup && !popup.frame.contains(gestureRecognizer.location(in: superview))
	}
	
	public override func willMove(toSuperview newSuperview: UIView?) {
		superview?.removeGestureRecognizer(dismissGestureRecogniser)
		newSuperview?.addGestureRecognizer(dismissGestureRecogniser)
	}
	
	public func presentPopup() {
		
		guard let superview = superview, !isPresentingPopup else {
			return
		}
		
		isPresentingPopup = true
		
		popup.delegate = self
		
		if popup.superview != superview {
			
			if popup.superview != nil {
				popup.removeFromSuperview()
			}
			
			superview.addSubview(popup)
			
			popup.translatesAutoresizingMaskIntoConstraints = false
			popup.topAnchor.constraint(equalTo: bottomAnchor).isActive = true
			popup.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
			popup.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
			popup.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor).isActive = true
			
			superview.layoutIfNeeded()
			
		}
		
		popup.backgroundColor = popupBackgroundColor
		popup.separatorStyle = popupSeparatorStyle
		
		popup.layer.cornerRadius = popupCornerRadius
		popup.clipsToBounds = true
		
		let initialFrame = popup.frame
		popup.frame = CGRect(origin: initialFrame.origin, size: CGSize(width: initialFrame.width, height: 0))
		
		delegate?.comboBoxView(self, willShowPopup: popup)
		
		UIView.animate(withDuration: 0.2) {
			self.popup.layer.opacity = 1
			self.popup.frame = initialFrame
		} completion: { [weak self] completed in
			guard let self = self else {
				return
			}
			
			self.delegate?.comboBoxView(self, didShowPopup: self.popup)
		}
	}
	
	public func resizePopup() {
		
		guard isPresentingPopup else {
			return
		}
		
		let initialHeight = popup.frame.height
		
		popup.invalidateIntrinsicContentSize()
		popup.layoutIfNeeded()
		
		let targetHeight = popup.frame.height
		
		popup.frame = CGRect(origin: frame.origin, size: .init(width: frame.width, height: initialHeight))
		
		UIView.animate(withDuration: 0.2) {
			self.popup.frame = CGRect(origin: self.frame.origin, size: .init(width: self.frame.width, height: targetHeight))
		}
	}
	
	@objc public func dismissPopup() {
		guard isPresentingPopup else {
			return
		}
		
		delegate?.comboBoxView(self, willDismissPopup: popup)
		
		UIView.animate(withDuration: 0.2) {
			self.popup.layer.opacity = 0
		} completion: { [weak self] completed in
			guard let self = self else {
				return
			}
			
			self.isPresentingPopup = false
			self.delegate?.comboBoxView(self, didDismissPopup: self.popup)
		}
	}
	
	
}
