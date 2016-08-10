#
# Be sure to run `pod lib lint StartAppsKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'StartAppsKit'
s.version          = '0.4.0'
s.summary          = 'A library that does everything.'
s.description      = <<-DESC
A library that does everything. Central class is LoadAction and it helps you work with asyncronus loading of data from any Source.
DESC
s.homepage         = 'https://github.com/StartAppsPe/StartAppsKit'
s.license          = 'MIT'
s.author           = { 'Gabriel Lanata' => 'gabriellanata@gmail.com' }

s.source           = { :git => 'https://github.com/StartAppsPe/StartAppsKit.git', :tag => s.version.to_s }
s.module_name      = 'StartAppsKit'
s.platform     = :ios, '8.0'
s.requires_arc = true

s.resource_bundles = {
    'StartAppsKit' => ['Pod/Assets/*']
}

s.default_subspec = 'Default'

s.subspec 'Default' do |sp|
sp.dependency 'StartAppsKit/ViewControllers'
sp.dependency 'StartAppsKit/LoadActions'
sp.dependency 'StartAppsKit/Extensions'
sp.dependency 'StartAppsKit/Animations'
sp.dependency 'StartAppsKit/Logging'
end

s.subspec 'Extensions' do |sp|
sp.source_files = 'Pod/Classes/Extensions'
sp.frameworks = 'UIKit'
end

s.subspec 'Animations' do |sp|
sp.source_files = 'Pod/Classes/Animations'
sp.frameworks = 'UIKit'
end

s.subspec 'Logging' do |sp|
sp.source_files = 'Pod/Classes/Logging'
end

s.subspec 'ViewControllers' do |sp|
sp.source_files = 'Pod/Classes/ViewControllers'
sp.dependency 'StartAppsKit/LoadActions'
sp.frameworks = 'UIKit'
end

s.subspec 'LoadActions' do |sp|
sp.source_files = 'Pod/Classes/LoadActions'
sp.dependency 'StartAppsKit/Extensions'
sp.dependency 'StartAppsKit/Logging'
sp.dependency 'SwiftyJSON', '~> 2.3'
end

#s.subspec 'LoadActions-Facebook' do |sp|
#sp.dependency 'StartAppsKit/LoadActions'
#sp.dependency 'Facebook-iOS-SDK'
#end

s.subspec 'LoadActions-Parse' do |sp|
sp.source_files = 'Pod/Classes/Parse'
sp.dependency 'StartAppsKit/LoadActions'
sp.dependency 'Parse', '~> 1.1'
end

s.subspec 'Hashing' do |sp|
sp.source_files = 'Pod/Classes/Hashing'
sp.dependency 'CommonCrypto', '~> 1.1'
end

end