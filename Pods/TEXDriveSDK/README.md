# AXA DIL TEX Library Usage

The AXA TEX Drive library is used by the Telematics Exchange Platform project to
collect data from mobile phones.

## Distribution

There is two ways to use the library.

### Using CocoaPod

If you have SSH read access to the TEX library, you can simply add this line to your Pod file:

    pod 'TEXDriveSDK', :git => 'git@github.com:axadil/drive-sdk-ios-next.git', :tag => 'v3.0.0'

The tag depends on the version you want to use. There is no need to add other
CocoaPod dependencies since they will be automatically fetched.

### Using the distributed framework file

The AXA DIL Telematic Exchange library can be distributed as `framework` file.
It already embeds any resources it may need, and is compatible for both the
simulator and the ARM architecture. The deliverable is a zip file containing the
following elements:

- `README.md`: this readme file
- `CHANGELOG.md`: description of the changes between each version
- `TexDriveSDK.framework`: the release version of the library, log outputs are disabled by default
- `Docs`: developer guides

The SDK uses some other libraries through CocoaPod. You must reference them in
your pod file.

```
pod 'RxSwift', '4.3'
pod 'RxCocoa', '4.3'
```

## Usage

1. In the `Info.plist` file of your application, you must add :
-  `NSLocationAlwaysUsageDescription`, `NSLocationWhenInUseUsageDescription` and `NSLocationAlwaysAndWhenInUseUsageDescription`, add a string for instance:

        "AXADrive needs to know the location of your vehicle."
 - `NSAppTransportSecurity`, add

    ```<dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>tex.dil.services</key>
            <dict>
            <!--Include to allow subdomains-->
            <key>NSIncludesSubdomains</key>
            <true/>
            <!--Include to allow HTTP requests-->
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <!--Include to specify minimum TLS version-->
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
            </dict>
        </dict>
    </dict>
 
 - `NSMotionUsageDescription`, add a string like 
 
        "AXADrive needs to know the motion of your vehicle."
 - `UIRequiredDeviceCapabilities`, add   `gyroscope` and `accelerometer`

2. In the Capabilities or your project configuration, the following background(`UIBackgroundModes`) modes must be enabled:
    - `Background Fetch`
    - `Location Updates`

3. You can then include the header file by using:

    - In Objective-c
    ```
        #import <TEXDriveSDK/TEXDriveSDK.h>
    ```
    - In Swift
    ```
        #import TEXDriveSDK
   ```
You will find more detailed information in the documentation regrouped in the `Docs` directory:

- [User Guide](./Docs/user-guide.md): how to develop with the library TODO
- [Logging](./Docs/logging.md): information on logging TODO
- [OBD MetaSystem](./Docs/obd-metasystem.md): how to use the MetaSystem OBD device TODO
