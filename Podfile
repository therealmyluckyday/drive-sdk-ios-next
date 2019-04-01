# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
workspace 'TexDrive'

def shared_pods
    pod 'RxSwift',  '~> 4.4'
    pod 'RxCocoa',  '~> 4.4'
    pod 'RxCoreLocation', '~>1.3'

    
end

target 'TexDriveApp' do
  pod 'Fabric'
  pod 'Crashlytics'
  shared_pods
  pod "TexDriveSDK", :path => "./TexDriveSDK.podspec"
#  pod 'TexDriveSDK', :git => 'git@github.com:axadil/drive-sdk-ios-next.git', :tag => 'v3.0.0'


  target 'TexDriveAppTests' do
    inherit! :search_paths
    
  end

end

target 'TexDriveSDK' do
  pod 'RxSwift',  '~> 4.4'
  pod 'RxSwiftExt',  '~> 3.4'
  pod 'RxCoreLocation', '~>1.3'
  pod 'RxCocoa',  '~> 4.4'
  pod 'GzipSwift',  '~> 4.1'
    project 'TexDriveSDK/TexDriveSDK.xcodeproj'
    
    target 'TexDriveSDKTests' do
        inherit! :search_paths
        # RxTest and RxBlocking make the most sense in the context of unit/integration tests
        pod 'RxBlocking', '~>4.4'
        pod 'RxTest', '~>4.4'
    end
end
