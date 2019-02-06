# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
workspace 'TexDrive'

def shared_pods
    use_frameworks!
    pod 'RxSwift', '4.3.1'
    pod 'RxCocoa', '4.3.1'
    
end

target 'TexDriveApp' do
  use_frameworks!
  pod 'Fabric', '~> 1.9.0'
  pod 'Crashlytics', '~> 3.12'
  pod "TexDriveSDK", :path => "./TexDriveSDK.podspec"
#  pod 'TexDriveSDK', :git => 'git@github.com:axadil/drive-sdk-ios-next.git', :tag => 'v3.0.0'
  shared_pods

  target 'TexDriveAppTests' do
    inherit! :search_paths
    
  end

end

target 'TexDriveSDK' do
    pod 'RxSwift', '4.3.1'
    pod 'RxSwiftExt', '3.4.0'
    pod 'RxCocoa', '4.3.1'
    pod 'GzipSwift', '~>4.0.4'
    project 'TexDriveSDK/TexDriveSDK.xcodeproj'
    
    target 'TexDriveSDKTests' do
        inherit! :search_paths
        # RxTest and RxBlocking make the most sense in the context of unit/integration tests
        pod 'RxBlocking', '4.3.1'
        pod 'RxTest', '4.3.1'
    end
end
