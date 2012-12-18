Pod::Spec.new do |s|
  s.name         = "calatrava"
  s.version      = "0.3.1"
  s.summary      = "See http://calatrava.github.com"
  s.description  = <<-DESC
                    Calatrava is a framework for developing cross-platform mobile
                    apps, while still providing the highest quality, native user
                    experience you need.

                    This pod provides the iOS support for Calatrava apps, and
                    can't be used on its own. Instead see:
                    [calatrava](http://calatrava.github.com)
                   DESC
  s.homepage     = "http://calatrava.github.com"

  s.license      = 'Apache (2.0)'

  s.author       = { "Giles Alexander" => "gga@thoughtworks.com" }
  s.source       = { :git => "https://github.com/calatrava/calatrava-ios.git", :tag => s.version.to_s }
  s.platform     = :ios, '5.0'

  s.source_files = 'calatrava-ios/**/*.{h,m,c}'
  s.resources    = ['calatrava-ios/Bridge/embeddedBridge.js',
                    'calatrava-ios/Bridge/webRuntime.html',
                    'calatrava-ios/Bridge/webRuntimeBridge.js']

  s.frameworks   = ['Foundation', 'UIKit', 'CoreGraphics']
  s.requires_arc = true
end
