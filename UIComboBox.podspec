Pod::Spec.new do |spec|
	spec.name = 'UIComboBox'
	spec.version = '0.0.19'
	spec.license = { :type => 'MIT' }
	spec.homepage = 'https://github.com/Kiwijane3/UIComboBox'
	spec.authors = { 'Jane Fraser' => 'janef0421@icloud.com' }
	spec.summary = 'A flexible control for UIKit that allows the user to select a single element from a dropdown.'
  spec.source = { :git => 'https://github.com/Kiwijane3/UIComboBox.git', :tag => 'v0.0.19'}
  spec.module_name = 'ComboBox'
  spec.swift_version = '5.6'
  spec.ios.deployment_target = '9.0'
  
  spec.source_files = 'ComboBox/*.swift'
  spec.ios.framework = 'UIKit'
  
  spec.dependency 'DiffableDataSources'
end