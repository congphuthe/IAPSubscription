Pod::Spec.new do |s|
  s.name             = "IAPSubscription"
  s.version          = "1.0.0"
  s.summary          = "The open source for IAP"
  s.homepage         = "https://github.com/congphuthe"
s.license          = {:type => "MIT", :file => "LICENSE"}
  s.author           = { "Cong" => "cong.phu@terralogic.com" }
  s.source           = { :git => "https://github.com/congphuthe/IAPSubscription.git", :tag => s.version }

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'IAPSubscription/**/*'

end
