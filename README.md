# UIComboBox

UIComboBox provides a basic drop-down selection control for iOS, similar to a `Spinner` for Android. The design of the code prioritises flexibility.

## Adding as a dependency

UIComboBox is available via Swift Package Manager and CocoaPods.

To add it as a Swift Package Manager dependency:

```swift
dependencies: [
	//...
	.package(url: "https://github.com/Kiwijane3/UIComboBox.git", .upToNextMinor(from: "0.1.0"))
	//...
]
```

To add it as a CocoaPods dependency:

```ruby
	//...
	pod 'UIComboBox', '~> 0.1.0'
	//...
```

## Getting Started

Once you have added the dependency, add a `ComboBoxView` to your view layout and need to define a data source to populate it. Similarly to `UITableViewCell`, `ComboBoxView` uses `UITableViewCell`s to display both the currently selected element and available elements in the dropdown. Define cells as you would for a table view using your preferred method (XIB or Class), and then register them with the combo box using the appropriate context; Use `.selection` for cells that will show the currently selected item in the combo box itself, or `.dropdown` for cells that will display available items in the dropdown. For instance:

```swift
public class MyViewController: UIViewController {
	//...
    weak var comboBox: ComboBoxView!
	//...
    public func viewDidLoad() {
		//...
		comboBox.register(UINib(nibName: "PlaceholderCell", bundle: nil), forCellWithReuseIdentifier: "placeholder", inContext: .selection)
        comboBox.register(UINib(nibName: "SelectionCell", bundle: nil), forCellWithReuseIdentifier: "selection", inContext: .selection)
        comboBox.register(MyDropDownCell.Self, forCellWithReuseIdentifier: "dropdown", inContext: .dropdown)
    	//...
	}
	//...
}
```

Then, define functions to generate cells for each of these contexts, like so:

```swift
public func generateSelectionCell(_ comboBox: ComboBoxView, forItem item: String?) -> UITableViewCell {
	if let item = item {
		let cell = comboBox.dequeueReusableCell(withIdentifier: "selection") as! SelectionCell
		cell.content.text = item
		return cell
	} else {
		return comboBox.dequeueReusableCell(withIdentifier: "placeholder")!
	}
}

public func generateItemCell(_ tableView: UITableView, atIndex index: IndexPath, forItem item: String) -> UITableViewCell {
	let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: index) as! ItemCell
	cell.content.text = item
	return cell
}
```

Then, create a data source that uses the functions to generate cells and add it to the combo box. You will need to set the `contents` property to selectable elements. Here is an example:

```swift
public func viewDidLoad() {
	//...
	dataSource = AdaptiveLinearComboBoxDataSource(
				selectionCellProvider: self.generateSelectionCell(_:forItem:),
				popupCellProvider: self.generateItemCell(_:atIndex:forItem:)
			)
	comboBox.dataSource = dataSource 
	dataSource.contents = ["Alpha", "Beta", "Gamma", "Kappa", "Epsilon", "Omega"]
	//...
}
```

## Compatibility

The library includes multiple default data source implementations for compatibility with different iOS versions. The `Diffable` data sources use the diffable data sources added in iOS 13, the `Compat` data sources handle updates manually and are compatible with all supported versions, and the `Adaptive` data sources delegate their behavior to one of these classes depending on the iOS version they are running on. The main advantage of the `Diffable` data sources is that they can automatically animate changes to the displayed contents. If you do not need to support OS versions prior to 13, then use it is probably best to use a `Diffable` data sources; Otherwise, an `Adaptive` data source is probably optimal.

## Styling the Dropdown

`ComboBoxView` has a variety of properties to style the drop-down used to display available options. These can be set in Interface Builder, or set programmatically; For more information, see the documentation for `ComboBoxView`

## Showing Nested Elements

`UIComboBox` includes built-in data sources that allows for displaying items in the expandable groups. To use these data sources, define and register your cells as above, and then define functions for group headers and items; Note that the item generation closure has an additional parameter indicating the group it is part of. Here is an example:

```swift
public func generateGroupHeaderCell(_ tableView: UITableView, atIndex index: IndexPath, forGroupWithId groupId: String, isExpanded expanded: Bool) -> UITableViewCell {
	let cell = tableView.dequeueReusableCell(withIdentifier: groupHeaderCellIdentifier, for: index) as! GroupHeaderCell	
	cell.content.text = groupId
	cell.expanded = expanded	
	cell.topMarginConstraint.isActive = index.section == 0 && index.row == 0	
	return cell
}
public func generateItemCell(_ tableView: UITableView, atIndex index: IndexPath, forItem item: String, inGroupWithId groupId: String?) -> UITableViewCell {
	let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: index) as! ItemCell
	cell.content.text = item
	cell.isInGroup = groupId != nil
	return cell	
}
```

Then, create an expandable data source using these functions and populate its contents using a `NestedList`.

```swift
override func viewDidLoad() {
	//...
	dataSource = AdaptiveExpandableComboBoxDataSource(
				selectionCellProvider: self.generateSelectionCell(_:forItem:),
				groupHeaderCellProvider: self.generateGroupHeaderCell(_:atIndex:forGroupWithId:isExpanded:),
				itemCellProvider: self.generateItemCell(_:atIndex:forItem:inGroupWithId:)
			)
	dataSource?.contents = [
		// Use .item to display a selectable element outside of a group
		.item(item: "Alpha"),
		// Or use .group to embed it in an expandable group
		.group(identifer: "Beta", items: ["Lambda", "Kappa"]),
		.group(identifer: "Gamma", items: ["Omega", "Delta", "Epsilon"])
	]
	comboBox.dataSource = dataSource
	comboBox.delegate = self
	//...
}
```
