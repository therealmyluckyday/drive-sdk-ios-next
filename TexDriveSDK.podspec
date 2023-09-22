Pod::Spec.new do |s|

# 1
s.platform = :ios
s.name = "TexDriveSDK"
s.summary = "TexDriveSDK"
s.requires_arc = true
s.version = "3.0.12"
s.homepage = "http://www.axa.com"
s.swift_version = '5.0'
s.ios.deployment_target  = '13.0'

s.author = { "therealmyluckyday" => "devs.myluckyday@gmail.com" }
s.source       = { :git => "https://github.com/therealmyluckyday/drive-sdk-ios-next", :tag => s.version.to_s }
s.license      = { :type => 'BSD' }
s.source_files  = "TexDriveSDK/TexDriveSDK/**/*.{h,m,c,swift}"
s.resources = "TexDriveSDK/TexDriveSDK/Resources/*"

s.dependency 'RxSwift', '~> 6.6'
s.dependency 'RxCocoa', '~> 6.6'
s.dependency 'RxSwiftExt', '~> 6.2'
s.dependency 'GzipSwift', '~> 5.1.1'
s.dependency 'RxCoreLocation', '~> 1.5.1'
s.dependency 'KeychainAccess', '~> 4.2.2'

end
