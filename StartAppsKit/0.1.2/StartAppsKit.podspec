#
# Be sure to run `pod lib lint StartAppsKit.podspec" to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = "StartAppsKit"
s.version          = "0.1.2"
s.summary          = "A library that does everything."

s.description      = <<-DESC
A library that does everything. Central class is LoadAction and it helps you work with asyncronus loading of data from any Source.
DESC

s.homepage         = "https://github.com/StartAppsPe/StartAppsKit"
s.license          = "MIT"
s.author           = { "Gabriel Lanata" => "gabriellanata@gmail.com" }
s.source           = { :git => "https://github.com/StartAppsPe/StartAppsKit.git", :tag => s.version.to_s }

s.platform     = :ios, "8.0"
s.requires_arc = true

s.source_files = "StartAppsKit", "Pod/Classes/*", "Pod/Classes/**/*"
s.resource_bundles = {
"StartAppsKit" => ["Pod/Assets/*.png"]
}

# s.public_header_files = "Pod/Classes/**/*.h"
# s.frameworks = "UIKit", "MapKit"
# s.dependency "AFNetworking", "~> 2.3"
end
