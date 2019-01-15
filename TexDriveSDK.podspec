Pod::Spec.new do |s|

# 1
s.platform = :ios
s.name = "TexDriveSDK"
s.summary = "TexDriveSDK"
s.requires_arc = true
s.version = "3.0.0"
s.homepage = "http://www.axa.com"
s.swift_version = '4.2'
s.ios.deployment_target  = '11.0'

s.author = { "vhiribarren" => "vhiribarren@users.noreply.github.com" }
s.source       = { :git => "https://github.com/axadil/tex-drive-sdk.git", :tag => "3.0.0" }

s.source_files  = "TexDriveSDK/TexDriveSDK/**/*.{h,m,c,swift}"
s.resources = "TEXDriveSDK/TEXDriveSDK/Resources/*"

s.dependency 'RxSwift'
s.dependency 'RxCocoa'
s.dependency 'RxBlocking'

end
