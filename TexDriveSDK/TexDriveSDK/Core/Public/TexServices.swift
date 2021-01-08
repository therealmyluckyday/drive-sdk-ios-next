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
        urlScoreSessionConfiguration.timeoutIntervalForResource = 15 * 60 * 60
        urlScoreSessionConfiguration.httpAdditionalHeaders = configuration.tripInfos.httpHeaders()
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos, urlSessionConfiguration: urlScoreSessionConfiguration)
        scoringClient = ScoreRetriever(sessionManager: scoreSessionManager, locale: configuration.locale)
        // Configure API Trip session
        let urlTripSessionConfiguration = isTesting ? URLSessionConfiguration.default : URLSessionConfiguration.background(withIdentifier: "TexSession")
        urlTripSessionConfiguration.isDiscretionary = true
        urlTripSessionConfiguration.sessionSendsLaunchEvents = true
        urlTripSessionConfiguration.timeoutIntervalForResource = 15 * 60 * 60
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
        os_log("[BGTASK] HandleStopRequest" , log: OSLog.texDriveSDK, type: OSLogType.info)
        guard let tripSessionManager = self._tripSessionManager else {
            os_log("[BGTASK] Error no tripsesionManager" , log: OSLog.texDriveSDK, type: OSLogType.error)
            return
        }
        let operationQueue = OperationQueue.main
        
        // Create an operation that performs the main part of the background task
        let operation = TexStopRequestOperation(tripSessionManager)
        
        // Provide an expiration handler for the background task
        // that cancels the operation
        task.expirationHandler = {
            os_log("[BGTASK] ExpirationHandler operation not completed" , log: OSLog.texDriveSDK, type: OSLogType.error)
            operation.cancel()
            task.setTaskCompleted(success: false)
        }
        
        // Inform the system that the background task is complete
        // when the operation completes
        operation.completionBlock = {
            os_log("[BGTASK] Operation completed" , log: OSLog.texDriveSDK, type: OSLogType.info)
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        // Start the operation
        os_log("[BGTASK] Start the operation" , log: OSLog.texDriveSDK, type: OSLogType.info)
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
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: BGAppTaskRequestIdentifier, using: .global()) { (task) in
                os_log("[BGTASK] My backgroundTask is executed now" , log: OSLog.texDriveSDK, type: OSLogType.info)
                if let task = task as? BGProcessingTask {
                    self.handleStopRequest(task)
                }
            }
        }
    }
}
