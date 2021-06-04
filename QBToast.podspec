Pod::Spec.new do |s|
  s.name             = 'QBToast'
  s.version          = '0.1.0'
  s.summary          = 'Toast message for iOS'

  s.description      = <<-DESC
TODO: Toast message for iOS written in Swift.
                       DESC

  s.homepage         = 'https://github.com/sjc-bui/QBToast'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sjc-bui' => 'bui@setjapan.co.jp' }
  s.source           = { :git => 'https://github.com/sjc-bui/QBToast.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'QBToast/Classes/**/*'

end
