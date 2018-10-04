# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
workspace 'TexDrive'
def shared_pods
    
    use_frameworks!
    
    pod 'Alamofire', '~> 4.7'
    pod 'RxSwift'
    pod 'RxCocoa'
    
end

target 'TexDriveApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  pod "TexDriveSDK", :path => "./TexDriveSDK.podspec"
  shared_pods

  target 'TexDriveAppTests' do
    inherit! :search_paths
    
  end

end

target 'TexDriveSDK' do
    pod 'Alamofire', '~> 4.7'
    pod 'RxSwift'
    pod 'RxCocoa'
    project 'TexDriveSDK/TexDriveSDK.xcodeproj'
    
    target 'TexDriveSDKTests' do
        inherit! :search_paths
        # RxTest and RxBlocking make the most sense in the context of unit/integration tests
        pod 'RxBlocking', '~> 4.0'
        pod 'RxTest',     '~> 4.0'
    end
end
