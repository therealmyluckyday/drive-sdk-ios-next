# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'
workspace 'TexDrive'
inhibit_all_warnings!

use_frameworks!
def shared_pods
    pod 'RxSwift' 
    pod 'RxCocoa'
    pod 'RxCoreLocation', :git => 'git@github.com:RxSwiftCommunity/RxCoreLocation.git', :branch => 'master'
end

target 'TexDriveApp' do
  shared_pods
  pod "TexDriveSDK", :path => "./TexDriveSDK.podspec"
#  pod 'TexDriveSDK', :git => 'git@github.com:axadil/drive-sdk-ios-next.git', :tag => 'v3.0.0'v3.0.0-alpha
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'

  target 'TexDriveAppTests' do
    inherit! :search_paths
    
  end

end

target 'TexDriveSDK' do
  shared_pods
  pod 'GzipSwift'
  pod 'KeychainAccess'
  project 'TexDriveSDK/TexDriveSDK.xcodeproj'

  target 'TexDriveSDKTests' do
    inherit! :search_paths
    pod 'GzipSwift'
  end
end
post_install do |installer_representation|
  
  installer_representation.pods_project.targets.each do |target|
    
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end

    xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`

    installer_representation.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        # For xcode 15+ only
        if config.base_configuration_reference && Integer(xcode_base_version) >= 15
          xcconfig_path = config.base_configuration_reference.real_path
          xcconfig = File.read(xcconfig_path)
          xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
          File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
        end
      end
    end

  end
end

