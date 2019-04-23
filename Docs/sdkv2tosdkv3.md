# AXA TEX Library Switch SDKV2 To SDK V3

### Table of Contents

1. [AXATexUser](#axatexuser)
2. [AXATexConfigBuilder](#axatexconfigbuilder)
3. [AxaPlatform](#axaplatform)
4. [Configure log](#configure-log)
5. [AXATexServices](#axatexservices)
5. [Automode](#automode)
6. [Start and Stop trip](#start-and-stop-trip)
)


### AXATexUser

SDKV2

```Swift
let texUser = AXATexUser(userId: userId, authToken: nil)
```

SDKV3

```Swift
let texUser = TexUser.Authentified(userId)
```

### AXATexConfigBuilder
## Init
SDKV2

```Swift
let builder = AXATexConfigBuilder(appId: appName, texUser: texUser)
```

SDKV3

```Swift
let builder = TexConfigBuilder(appId: appName, texUser: texUser)
```

## Enable Trip Recorder
SDKV2

```Swift
builder.enableTripRecorder()
```

SDKV3
With the new SDKV3 you can now have exception you need to manage.
You should ask GPS and Motion Access before configuring the SDK.
```Swift
do {
    try builder.enableTripRecorder()
    } catch ConfigurationError.LocationNotDetermined(let description) {
        print(description)
    } catch {
        print("\(error)")
    }
```

## Enable AutoMode

SDKV2

```Swift
    builder.enableAutoMode()
```

SDKV3
Prior to SDKV3, you was able to enable automode before the `TexConfig` creation.
Now you need to Activate Automode after `TexService` Creation
```Swift
let config = builder.build()
let texServices = TexServices.service(configuration: config)
texServices.tripRecorder?.activateAutoMode()
```


### AXAPlatform
SDKV2

```Swift
if let platformRow = AXAPlatform(raw: platform) {
    builder.select(platformRow)
}
```

SDKV3

```Swift
builder.select(platform: Platform.Production)
```

### Configure log
We are no longer using cocoaLumberJack log, we now use rx to Log.
See configureLog function on 
- [Logging](./logging.md): 

```Swift
self.configureLog(texServices!.logManager.rxLog)
```

### AXATexServices
#### Init
SDKV2

```Swift
let config = builder.build()
if let texServices = AXATexServices.configure(config) {
...
}
```

SDKV3

```Swift
let config = builder.build()
let texServices = TexServices.service(configuration: config)
```

### AutoMode
#### Activate
SDKV2
You were able to activate automode like this :
```Swift
texServices.autoMode?.startService()
```

SDKV3
Now, you activate automode like this :
```Swift
texServices.tripRecorder.activateAutoMode()
```

#### Disable
SDKV2
You were able to disable automode like this :
```Swift
texServices.autoMode?.stopService()
```

### Start and Stop trip
#### Manually Start
SDKV2
```Swift
if !texServices.tripRecorder.isRecording {
    texServices.tripRecorder.startTrip(with: .manual)
    if texServices.autoMode?.isServiceStarted ?? false {
        texServices.autoMode?.forceStatusDriving()
    }
}
```
SDKV3
```Swift
if !texServices.tripRecorder.isRecording {
    texServices.tripRecorder.start()
    if texServices.autoMode?.isServiceStarted ?? false {
        texServices.autoMode?.forceStatusDriving()
    }
}
```
#### Manually Stop

SDKV2
```Swift
if texServices.tripRecorder.isRecording {
    texServices.tripRecorder.stopTrip(with: .manual)
    if texServices.autoMode?.isServiceStarted ?? false {
        texServices.autoMode?.forceStatusWaitingScanTrigger()
        }
}
```

SDKV3
```Swift
if texServices.tripRecorder.isRecording {
    texServices.tripRecorder.stopTrip()
    if texServices.autoMode?.isServiceStarted ?? false {
        texServices.autoMode?.forceStatusWaitingScanTrigger()
    }
}
```
