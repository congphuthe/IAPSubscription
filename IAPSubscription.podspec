Pod::Spec.new do |s|
  s.name             = “IAPSubscription”
  s.version          = “1.0.0”
  s.summary          = "The open source fonts for IAPSubscription."
  s.homepage         = "https://github.com/congphuthe/IAPSubscription"
  s.license          = 'Code is MIT, then custom font licenses.'
  s.author           = { "Orta" => “cong.phu@terralogic.com” }
  s.source           = { :git => "https://github.com/congphuthe/IAPSubscription.git", :tag => s.version }

  s.platform     = :ios, ‘9.0’
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*'

  s.frameworks = 'UIKit', 'StoreKit’, ‘SystemConfiguration’
  s.module_name = 'IAPSubscription'
end