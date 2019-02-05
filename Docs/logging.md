# Logging Usage

The AXA TEX Drive library used rxswift to send message.
It will be up to client library to choose using or not the logging system

## Public Usage

### Using RX
When you initialize your configuration you can after retrieve the `rxLog` property a `PublishSubject<LogMessage>` class on the LogManager contains in the TexService class. 

Then you can create a function like that :
    
    func configureLog(_ log: PublishSubject<LogMessage>) {
        log.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
            if let logMessage = event.element {
                print("\(logMessage)")
            }
        }.disposed(by: self.rxDisposeBag)

    }

### Extra
The `LogMessage `object can give you advanced detail like, the `type` of log, the `filename` `functionname` associated and the `message` description.
`LogMessage` is `CustomStringConvertible` so you can just looked at his `description` variable.


## Internal Usage

If you want to change implementation you can create a class compatible to the LogImplementation protocol on `Log.swift`.
Then on `Config.swift` you have to change the logFactory with your implementation (Currently `LogRx`).


