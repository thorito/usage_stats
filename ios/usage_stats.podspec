#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint usage_stats.podspec' to validate before publishing.
#
# This plugin is Android-only and does not support iOS.
Pod::Spec.new do |s|
  s.name             = 'usage_stats'
  s.version          = '0.0.1'
  s.summary          = 'Android-only plugin for usage statistics.'
  s.description      = <<-DESC
This plugin is Android-only and does not support iOS.
                       DESC
  s.homepage         = 'https://github.com/Parassharmaa/usage_stats'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Paras Sharma' => 'parassharmaa@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.9'
end
