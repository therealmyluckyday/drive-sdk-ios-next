//
//  Service.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift
import OSLog
#if canImport(BackgroundTasks)
import BackgroundTasks
#endif


extension OSLog {
    private static var texsubsystem = Bundle.main.bundleIdentifier!
    
    static let texDriveSDK = OSLog(subsystem: texsubsystem, category: "TexDriveSDK")
}

public class TexServices {
    // MARK: - Property
    // MARK: - Public
    public let logManager = LogManager()
    public let rxScore = PublishSubject<Score>()
    
    /*
     @available(swift 5.3)
     @LateInitialized public var tripRecorder: TripRecorder
     
     @available(swift 5.3)
     @LateInitialized public var scoringClient: ScoringClient
     
     // MARK: - Private
     
     @available(swift 5.3)
     @LateInitialized private var _tripSessionManager: APITripSessionManager
     
     */
    public var tripRecorder: TripRecorder?
    public var scoringClient: ScoringClient?
    
    // MARK: - Private
    private var _tripSessionManager: APITripSessionManager?
    
    
    private static let sharedInstance = TexServices()
    
    // MARK: - Internal
    internal var configuration: ConfigurationProtocol?
    internal var disposeBag: DisposeBag?
    
    // MARK: - Internal Method
    internal func reconfigure(_ configuration: ConfigurationProtocol, isTesting: Bool) {
        let rxDisposeBag = DisposeBag()
        disposeBag = rxDisposeBag
        self.configuration = configuration
        // Configure API Score session
        let urlScoreSessionConfiguration = URLSessionConfiguration.default
        urlScoreSessionConfiguration.timeoutIntervalForResource = 2 * 60
        urlScoreSessionConfiguration.httpAdditionalHeaders = configuration.tripInfos.httpHeaders()
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos, urlSessionConfiguration: urlScoreSessionConfiguration)
        scoringClient = ScoreRetriever(sessionManager: scoreSessionManager, locale: configuration.locale)
        // Configure API Trip session
        let urlTripSessionConfiguration = isTesting ? URLSessionConfiguration.default : URLSessionConfiguration.background(withIdentifier: "TexSession")
        urlTripSessionConfiguration.isDiscretionary = false
        urlTripSessionConfiguration.shouldUseExtendedBackgroundIdleMode = true
        urlTripSessionConfiguration.sessionSendsLaunchEvents = true
        urlTripSessionConfiguration.timeoutIntervalForResource = 2 * 60 * 60
        urlTripSessionConfiguration.httpAdditionalHeaders = configuration.tripInfos.httpHeaders()
        let tripSessionManager = APITripSessionManager(configuration: configuration.tripInfos, urlSessionConfiguration: urlTripSessionConfiguration)
        _tripSessionManager = tripSessionManager
        self.configureTripRecorder(configuration: configuration, sessionManager: tripSessionManager)
    }
    
    internal func configureTripRecorder(configuration: ConfigurationProtocol, sessionManager: APITripSessionManager) {
        tripRecorder = TripRecorder(configuration: configuration, sessionManager: sessionManager)
    }
    
    @available(iOS 13.0, *)
    func handleStopRequest(_ task: BGProcessingTask) {
        Log.print("[BGTASK] HandleStopRequest")
        guard let tripSessionManager = self._tripSessionManager else {
            Log.print("[BGTASK] Error no tripsesionManager", type: .Error)
            return
        }
        let operationQueue = OperationQueue.main
        
        // Create an operation that performs the main part of the background task
        let operation = TexDriveSDK.TexStopRequestOperation(tripSessionManager)
        
        // Provide an expiration handler for the background task
        // that cancels the operation
        task.expirationHandler = {
            Log.print("[BGTASK] ExpirationHandler operation not completed", type: .Error)
            operation.cancel()
            task.setTaskCompleted(success: false)
        }
        
        // Inform the system that the background task is complete
        // when the operation completes
        operation.completionBlock = {
            Log.print("[BGTASK] Operation completed")
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        // Start the operation
        Log.print("[BGTASK] Start the operation")
        operationQueue.addOperation(operation)
        
    }
    
    // MARK: - Public Method
    public class func service(configuration: ConfigurationProtocol, isTesting: Bool = false) -> TexServices {
        if sharedInstance.tripRecorder != nil {
            sharedInstance.tripRecorder?.autoMode?.disable()
            sharedInstance.tripRecorder?.stop()
        }
        sharedInstance.reconfigure(configuration, isTesting: isTesting)
        return sharedInstance
    }
    
    public func registerBGTaskScheduler() {
        if #available(iOS 13.0, *) {
            self.checkStopRequest()
            BGTaskScheduler.shared.register(forTaskWithIdentifier: BGAppTaskRequestIdentifier, using: .global()) { (task) in
                Log.print("[BGTASK] My backgroundTask is executed now")
                if let task = task as? BGProcessingTask {
                    self.handleStopRequest(task)
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    func checkStopRequest() {
        Log.print("[TexService] HandleStopRequest")
        guard let tripSessionManager = self._tripSessionManager else {
            Log.print("[TexService] Error no tripsesionManager", type: .Error)
            return
        }
        let operationQueue = OperationQueue.main
        
        // Create an operation that performs the main part of the background task
        let operation = TexDriveSDK.TexStopRequestOperation(tripSessionManager)
        
        // Inform the system that the background task is complete
        // when the operation completes
        operation.completionBlock = {
            Log.print("[TexService] Operation completed")
            Log.print("[TexService] CancelScheduleBGTask")
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: BGAppTaskRequestIdentifier)
        }
        
        // Start the operation
        Log.print("[TexService] Start the operation")
        operationQueue.addOperation(operation)
    }
}
