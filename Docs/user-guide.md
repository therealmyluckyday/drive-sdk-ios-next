# AXA TEX Library Usage

### Table of Contents

1. [Main Project Configuration](#main-project-configuration)
2. [TEX Services Configuration](#tex-services-configuration)
3. [Trip Recorder and score](#trip-recorder-and-score)
4. [Configure log](#configure-log)
5. [Manual trip recording](#manual-trip-recording)
5. [Automode trip recording](#automode-trip-recording)
6. [Switch SDKV2 to SDKV3](#SDKV2-to-SDKV3)
)


### Main Project Configuration

You can read the [README.md](../README.md) file giving the steps to integrate
the library.

### TEX Services Configuration

Before using the TEX Drive SDK, a configuration object must be created. It
defines configuration which scope is the whole SDK.
Be carefull it can throw exception if prerequire are not fulfill.

Once created, this configuration allows you to create a `TexServices` object
that contains or create instances of the different services of the SDK.

The `TexServices` instance that is created should be stored in your
application delegate since only one instance of it must exist. The decoupling
configuration / instance creation was specifically made to be sure only one
instance of `TexServices` will be created.

A reconfiguration procedure is possible (e.g. if you want to change the user
login): in this case the previous `AXATexService` instance is still valid, but
all services depending on it will be reconfigured with the new configuration.

Example of configuration creation:

```swift

// Configuration
///////////////////////////////////////////////////////////////////////////////////////////

// Build configuration
func configureTexSDK(withUserId: String) {
    let user = User.Authentified(withUserId)

    do {
        if let configuration = try Config(applicationId: "APP-TEST", applicationLocale: Locale.current, currentUser: user) {
            texServices = TexServices.service(reconfigureWith: configuration)
        }
    } catch ConfigurationError.LocationNotDetermined(let description) {
        print(description)
    } catch {
        print("\(error)")
    }
}

// Once created, texServices should be stored and retrieved from the app delegate object

// ...
// Utilization of the library
// ...


```





### Trip Recorder and score

```swift
    // Received Trip score texServices?.rxScore.asObserver().observeOn(MainScheduler.asyncInstance).retry().subscribe({ (event) in
        if let score = event.element {
            print("New score \(score)")
        }
    }).disposed(by: rxDisposeBag)

```

### Configure log
See configureLog function on 
- [Logging](./logging.md): 

```Swift
    self.configureLog(texServices!.logManager.rxLog)
```
### Manual trip recording
#### Start
```Swift
texServices?.tripRecorder.start()
```
#### Stop
You can call the stop function when :
- you drive during more than 5 minutes
- you drive at least 4km
```Swift
texServices?.tripRecorder.stop()
```
### AutoMode trip recording
#### Activate Automode
```Swift
texServices?.tripRecorder.activateAutoMode()
```
#### Disable Automode
```Swift
texServices?.tripRecorder.disableAutoMode()
```

### SDKV2 to SDKV3
See how to switch on 
- [Switch](./sdkv2tosdkv3.md): 


