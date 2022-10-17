// swift-tools-version:5.0
import PackageDescription

let package = Package(
	name: "UIComboBox",
	platforms: [
		.iOS(.v9)
	],
	products: [
		.library(name: "ComboBox", targets: ["ComboBox"])
	],
	targets: [
		.target(
			name: "ComboBox"
		)
	]
)