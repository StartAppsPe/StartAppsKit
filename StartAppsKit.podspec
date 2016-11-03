#
# Be sure to run `pod lib lint StartAppsKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'StartAppsKit'
s.version          = '1.0.0'
s.summary          = 'A library that does everything.'
s.description      = <<-DESC
A library that does everything. Central class is LoadAction and it helps you work with asynchronous loading of data from any Source.
DESC
s.homepage         = 'https://github.com/StartAppsPe/'+s.name
s.license          = 'MIT'
s.author           = { 'Gabriel Lanata' => 'gabriellanata@gmail.com' }

s.source           = { :git => 'https://github.com/StartAppsPe/'+s.name+'.git', :tag => s.version.to_s }
s.module_name      = s.name
s.platform         = :ios, '8.0'
s.requires_arc     = true

s.default_subspec = 'Default'

s.subspec 'Default' do |sp|
sp.source_files = 'Sources'
sp.dependency 'StartAppsKit/LoadAction'
sp.dependency 'StartAppsKit/Extensions'
sp.dependency 'StartAppsKit/Animations'
sp.dependency 'StartAppsKit/Alerts'
sp.dependency 'StartAppsKit/Logger'
end

#
# Default dependancies
#

s.subspec 'LoadAction' do |sp|
sp.dependency 'StartAppsKitLoadAction', '~> 1'
end

s.subspec 'Extensions' do |sp|
sp.dependency 'StartAppsKitExtensions', '~> 1'
end

s.subspec 'Animations' do |sp|
sp.dependency 'StartAppsKitAnimations', '~> 0.9'
end

s.subspec 'Alerts' do |sp|
sp.dependency 'StartAppsKitAlerts', '~> 0.9'
end

s.subspec 'Logger' do |sp|
sp.dependency 'StartAppsKitLogger', '~> 1'
end

#
# Optional dependancies
#

s.subspec 'JSON' do |sp|
sp.dependency 'StartAppsKitJson', '~> 1'
end

s.subspec 'XML' do |sp|
sp.dependency 'StartAppsKitXml', '~> 1'
end

end
