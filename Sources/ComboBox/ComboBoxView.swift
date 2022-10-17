//
//  NestedDropDownView.swift/Volumes/SFSymbols
//  NestedDropDown
//
//  Created by dev on 16/09/22.
//

import UIKit

/**
 
 A `ComboBoxView` is a `UIView` that allows a user to select a single option from a dropdown, similar to Android's `Spinner` or Gtk's `ComboBox`.
 It uses a ``ComboBoxDataSource`` to provide its content.
 
 */
@objc public class ComboBoxView: UIView, UITableViewDelegate, UIGestureRecognizerDelegate {
	
	public typealias Delegate = ComboBoxViewDelegate
	
	/// Represents an area in which a ``ComboBoxView`` displays its contents.
	public enum CellContext {
		/**
		 The content  shown in the ``ComboBoxView`` itself to represent the currently selected item.
		 
		 Cells registered in this context are managed by the combo box itself, and  can be dequeued via the ``ComboBoxView/dequeueReusableCell(withIdentifier:)`` method.
		 */
		case selection
		/**
		 The content shown in the drop-down to represent the available items.
		 
		 Cells registered in this context are managed by the `UITableView` used to display the combo box's dropdown,
		 and can be dequeued from the table view passed to the drop-down cell generators.
		 */
		case dropdown
	}
	
	private enum CellRegistryEntry {
		case nib(nib: UINib)
		case cellClass(cellClass: UITableViewCell.Type)
	}
	
	private var cellRegistry: [String: CellRegistryEntry] = [:]
	
	private var dropdown = ComboBoxPopupView()
	
	private var dropdownCollapsedConstraint: NSLayoutConstraint!
	
	private var dropdownMarginConstraint: NSLayoutConstraint?
	
	private var recycler: [String: UITableViewCell] = [:]
	
	/// The ``ComboBoxDataSource`` used to populate this ComboBoxView
	public weak var dataSource: ComboBoxDataSource? = nil {
		didSet {
			dataSource?.installedIn(comboBox: self)
			dataSource?.installDataSource(inTableView: dropdown)
			selectionDidChange()
		}
	}
	
	/// The ``ComboBoxViewDelegate`` that this ComboBoxView sends events to.
	public var delegate: ComboBoxViewDelegate?
	
	/**
	The corner radius of this popup view.
	 
	When this is set to a value greater than zero, this view's `clipsToBounds` property will be set to true.
	 */
	@IBInspectable
	public var cornerRadius: CGFloat = 8
	
	/// The vertical margin between this `ComboBoxView` and its drop-down.
	///
	/// The default value is 0, which indicates no margin.
	@IBInspectable
	public var dropdownMargin: CGFloat = 0
	
	/// The background color of the drop-down.
	@IBInspectable
	public var dropdownBackgroundColor: UIColor?

	/// The style of the separator displayed between elements in the drop-down.
	///
	/// The default value is `UITableViewCell.SeparatorStyle.none`.
	@IBInspectable
	public var dropdownSeparatorStyle: UITableViewCell.SeparatorStyle = .none
	
	/// The corner radius of the drop-down
	///
	/// The default value is 8.
	@IBInspectable
	public var dropdownCornerRadius: CGFloat = 8
	
	/// The view in which the drop-down will be embedded. If this is nil (which is the default), then the drop-down will be embedded in this view's superview.
	///
	/// The drop-down is constrained to appear within the bounds of its superview. If this ComboBoxView is placed within a small subview,
	/// it may be necessary to set this property to another view, such as the relevant `UIViewController`'s root view, in order for the drop-down to be properly displayed.
	@IBInspectable
	public var dropdownContainerView: UIView? {
		didSet {
			installDismissalGestureInPopupContainer()
		}
	}
	
	/// The ``UITableViewCell`` currently being used to display the selection on this combobox.
	private var currentSelectionCell: UITableViewCell?
	
	/// Whether the selection dropdown is currently displayed.
	private var isPresentingDropdown: Bool = false {
		didSet {
			dropdown.isHidden = !isPresentingDropdown
		}
	}
	
	/// The gesture recogniser used to dismiss the drop-down when the user selects outside of it.
	private var dismissGestureRecogniser: UITapGestureRecognizer!
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		configure()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		configure()
	}
	
	private func configure() {
		
		if cornerRadius > 0 {
			layer.cornerRadius = cornerRadius
			clipsToBounds = true
		}
		
		dropdownCollapsedConstraint = dropdown.heightAnchor.constraint(equalToConstant: 0)
		dropdownCollapsedConstraint.isActive = true
		
		dismissGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissDropdown))
		dismissGestureRecogniser.cancelsTouchesInView = false
		dismissGestureRecogniser.delegate = self
		
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
	}
	
	/// Registers the given `UINib` to be used to generate cells for display in the given context.
	///
	/// - Parameters:
	/// 	- nib: The `UINib` that provides cells to be displayed. Any nib used with this method should contain at least one root-level `UITableViewCell`.
	///		- reuseIdentifier: The reuse identifier used to identify cell kinds for recycling. This should not be an empty string.
	///		- context: The ``CellContext`` that the nib provides cells for.
	public func register(_ nib: UINib, forCellWithReuseIdentifier reuseIdentifier: String, inContext context: CellContext) {
		switch context {
			case .selection:
				cellRegistry[reuseIdentifier] = .nib(nib: nib)
			case .dropdown:
				dropdown.register(nib, forCellReuseIdentifier: reuseIdentifier)
		}
	}
	
	/// Registers a `UITableViewCell` class to be displayed in the given context.
	///
	/// Cells will be generated using the `UITableView/init(style:reuseIdentifier)` initialiser.
	///
	/// - Parameters:
	/// 	- cellClass: The `UITableViewCell` class to be displayed.
	///		- reuseIdentifier: The reuse identifier used to identify cell kinds for recycling. This should not be an empty string.
	///		- context: The ``CellContext`` that cells of this class will be displayed in.
	public func register(_ cellClass: UITableViewCell.Type, forCellWithReuseIdentifier reuseIdentifier: String, inContext context: CellContext) {
		switch context {
			case .selection:
				cellRegistry[reuseIdentifier] = .cellClass(cellClass: cellClass)
			case .dropdown:
				dropdown.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
		}
	}
	
	/// Returns a reusable cell to be displayed in the combo box itself.
	///
	/// The provided identifier should correspond to a cell kind that was registered for ``CellContext/selection`` via ``register(_:forCellWithReuseIdentifier:inContext:)-140lw`` or ``register(_:forCellWithReuseIdentifier:inContext:)-82xlp``;
	/// Otherwise, this method will return `nil`.
	/// If an existing cell is available, it will be provided, otherwise a new cell will be generated. A reused cell will have its `UITableViewCell.prepareForReuse`
	/// method called before being returned.
	///
	/// - Parameter identifier: The reuse identifier corresponding to the kind of cell that is required.
	///
	/// - Returns: A `UITableViewCell`  with the specified `identifier`, or `nil` if no such cell kind was registered.
	public func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
		if let recycled = recycler[identifier] {
			recycler[identifier] = nil
			recycled.prepareForReuse()
			return recycled
		} else {
			return generateReusableCell(withIdentifier: identifier)
		}
	}
	
	private func generateReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
		switch cellRegistry[identifier] {
			case .nib(let nib):
				return nib.instantiate(withOwner: nil).compactMap { object in
						return object as? UITableViewCell
					}.first
			case .cellClass(let cellClass):
				return cellClass.init(style: .default, reuseIdentifier: identifier)
			default:
				return nil
		}
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		dataSource?.didSelectCell(atIndex: indexPath, for: self)
	}
 
	/// Informs the ``ComboBoxView`` that the selected item has changed and it should update the displayed selection.
	public func selectionDidChange() {
		
		delegate?.comboBoxViewDidChangeSelection(self)
		
		guard let dataSource = dataSource else {
			return
		}

		let newView = dataSource.cellForDisplayingSelection(in: self)
		
		if let newView = newView {
			
			addSubview(newView)
			
			newView.layer.opacity = 0
			newView.translatesAutoresizingMaskIntoConstraints = false
			newView.contentView.translatesAutoresizingMaskIntoConstraints = false
			
			newView.contentView.topAnchor.constraint(equalTo: newView.topAnchor).isActive = true
			newView.contentView.leftAnchor.constraint(equalTo: newView.leftAnchor).isActive = true
			newView.contentView.rightAnchor.constraint(equalTo: newView.rightAnchor).isActive = true
			newView.contentView.bottomAnchor.constraint(equalTo: newView.bottomAnchor).isActive = true
			
			newView.topAnchor.constraint(equalTo: topAnchor).isActive = true
			newView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
			newView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
			newView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
			
		}
		
		UIView.animate(withDuration: 0.5) {
			newView?.layer.opacity = 1
			self.currentSelectionCell?.layer.opacity = 0
		} completion: { [weak self] completed in
			guard completed, let self = self else { return }
				
			self.currentSelectionCell?.removeFromSuperview()
			self.recycle(self.currentSelectionCell)
			self.currentSelectionCell = newView
		}
		
	
		self.dismissDropdown()
		
	}
	
	private func recycle(_ cell: UITableViewCell?) {
		guard let cell = cell, let reuseIdentifier = cell.reuseIdentifier else {
			return
		}

		if recycler[reuseIdentifier] == nil {
			recycler[reuseIdentifier] = cell
		}
	}
	
	@objc func onTap() {
		if isPresentingDropdown {
			dismissDropdown()
		} else {
			presentDropdown()
		}
	}
	
	public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard gestureRecognizer == dismissGestureRecogniser else {
			return true
		}
		
		return isPresentingDropdown && !dropdown.frame.contains(gestureRecognizer.location(in: dropdown.superview))
	}
	
	public override func didMoveToSuperview() {
		installDismissalGestureInPopupContainer()
	}
	
	private func installDismissalGestureInPopupContainer() {
		
		guard let popupContainerView = dropdownContainerView ?? superview, popupContainerView != dismissGestureRecogniser.view else {
			return
		}

		dismissGestureRecogniser.view?.removeGestureRecognizer(dismissGestureRecogniser)
		popupContainerView.addGestureRecognizer(dismissGestureRecogniser)
		
	}
	
	/// Displays the drop-down to allow the user to select an element.
	public func presentDropdown() {
		
		guard let dropdownParent = dropdownContainerView ?? superview, !isPresentingDropdown else {
			return
		}
		
		delegate?.comboBoxView(self, willShowDropdown: dropdown)
		
		dropdown.comboBox = self
		
		isPresentingDropdown = true
		
		dropdown.delegate = self
		
		if dropdown.superview != dropdownParent {
			
			if dropdown.superview != nil {
				dropdown.removeFromSuperview()
			}
			
			dropdownParent.addSubview(dropdown)
			
			dropdown.translatesAutoresizingMaskIntoConstraints = false
			dropdown.topAnchor.constraint(equalTo: bottomAnchor, constant: dropdownMargin).isActive = true
			dropdown.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
			dropdown.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
			dropdown.bottomAnchor.constraint(lessThanOrEqualTo: dropdownParent.bottomAnchor).isActive = true
			
		}
		
		dropdownParent.layoutIfNeeded()
		
		dropdown.backgroundColor = dropdownBackgroundColor
		dropdown.separatorStyle = dropdownSeparatorStyle
		
		dropdown.layer.cornerRadius = dropdownCornerRadius
		dropdown.clipsToBounds = true
		
		dropdownCollapsedConstraint.isActive = false
		
		UIView.animate(withDuration: 0.3) {
			self.dropdown.layer.opacity = 1
			dropdownParent.layoutIfNeeded()
		} completion: { [weak self] completed in
			guard completed, let self = self else {
				return
			}
			
			self.delegate?.comboBoxView(self, didShowDropdown: self.dropdown)
		}
	}
	
	/// Indicates that the dropdown's size should be updated.
	///
	/// The built-in ``ComboBoxDataSource`` implementations call this automatically based on updates to their contents,
	/// so you will likely only need to call this method if you are implemented a custom data source.
	public func dropDownSizeChanged() {
		
		guard isPresentingDropdown else {
			return
		}
		
		let initialFrame = dropdown.frame
		
		dropdown.invalidateIntrinsicContentSize()
		dropdown.layoutIfNeeded()
		
		let targetHeight = dropdown.frame.height
		
		dropdown.frame = initialFrame
		
		UIView.animate(withDuration: 0.3) {
			self.dropdown.frame = CGRect(origin: initialFrame.origin, size: .init(width: initialFrame.width, height: targetHeight))
		}
	}
	
	/// Hides the drop-down if it is currently displayed.
	@objc public func dismissDropdown() {
		guard isPresentingDropdown else {
			return
		}
		
		delegate?.comboBoxView(self, willDismissDropdown: dropdown)
		
		dropdownCollapsedConstraint.isActive = true
		
		UIView.animate(withDuration: 0.3) {
			self.dropdown.layer.opacity = 0
			self.dropdown.superview?.layoutIfNeeded()
		} completion: { [weak self] completed in
			guard completed, let self = self else {
				return
			}
			
			self.isPresentingDropdown = false
			self.delegate?.comboBoxView(self, didDismissDropdown: self.dropdown)
		}
	}
	
	
}
