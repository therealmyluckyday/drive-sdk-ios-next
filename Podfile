# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
workspace 'TexDrive'
inhibit_all_warnings!
def shared_pods
    pod 'RxSwift' 
    pod 'RxCocoa'
    pod 'RxCoreLocation'
end

target 'TexDriveApp' do
  shared_pods
  pod "TexDriveSDK", :path => "./TexDriveSDK.podspec"
#  pod 'TexDriveSDK', :git => 'git@github.com:axadil/drive-sdk-ios-next.git', :tag => 'v3.0.0'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'

  target 'TexDriveAppTests' do
    inherit! :search_paths
    
  end

end

target 'TexDriveSDK' do
  shared_pods
  pod 'RxSwiftExt'
  pod 'GzipSwift'  
  project 'TexDriveSDK/TexDriveSDK.xcodeproj'

  target 'TexDriveSDKTests' do
    inherit! :search_paths
  end
end
