Pod::Spec.new do |s|

# 1
s.platform = :ios
s.name = "TexDriveSDK"
s.summary = "TexDriveSDK"
s.requires_arc = true
s.version = "3.0.0"
s.homepage = "http://www.axa.com"
s.swift_version = '5.0'
s.ios.deployment_target  = '10.0'

s.author = { "vhiribarren" => "vhiribarren@users.noreply.github.com" }
s.source       = { :git => "https://github.com/axadil/drive-sdk-ios-next.git", :tag => "v3.0.0-alpha" }

s.source_files  = "TexDriveSDK/TexDriveSDK/**/*.{h,m,c,swift}"
s.resources = "TexDriveSDK/TexDriveSDK/Resources/*"

s.dependency 'RxSwift', '~> 5.1.1'
s.dependency 'RxCocoa', '~> 5.1.1'
s.dependency 'RxSwiftExt', '~> 5'
s.dependency 'GzipSwift', '~> 5.1.1'
s.dependency 'RxCoreLocation', '~> 1.5.0'


end
