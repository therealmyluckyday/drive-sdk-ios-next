//
//  SwiftUIViewTOTO.swift
//  TexDriveApp
//
//  Created by Erwan Masson on 02/10/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import SwiftUI
import TexDriveSDK
import RxSwift


struct HomeViewControllerSUI: View {
    let tripRecorder: TripRecorder
    let texServices: TexServices
    
    lazy var currentTripId = { () -> TripId in
        if let tripId = tripRecorder.currentTripId {
            return tripId
        }
        return TripId(uuidString: "0FDA9008-F429-4F53-9D8E-F3964B2CAF62")!
    }()
    
   
    
    let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
    let rxDisposeBag = DisposeBag()
    @State var selection = 0
    @State var selectionDrivingState = BooleanState.False
    @State var selectionTripState = BooleanState.False
    @State var items = ["On1", "Off"]
    @State var logs = "No Log"
    
    init(texServices: TexServices, tripRecorder: TripRecorder) {
        //self.showOldLog(cleanOld: false)
        print("initSwuiftUI")
        self.texServices = texServices
        self.tripRecorder = tripRecorder
        self.configureTexSDK(withUserId: userId)
    }
    
    func configureTexSDK(withUserId: String) {
        print("configureTexSDK")
        //Crashlytics.crashlytics().setUserID(userName)
       tripRecorder.tripIdFinished.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let tripId = event.element {
                //self.logs = "\n Trip finished: \n \(tripId.uuidString)"
                
                logs.append("\n Trip finished: \n \(tripId.uuidString)")
                print( "\n Trip finished: \n \(tripId.uuidString)")
                print( "\n Trip finished: \n \(Thread.current.isMainThread)")
                //self?.saveLog("\n Trip finished: \n \(tripId.uuidString)")
            }
            }.disposed(by: rxDisposeBag)
        tripRecorder.rxFix.asObserver().observeOn(MainScheduler.asyncInstance).subscribe({ (event) in
            if let fix = event.element {
                //print("FIX: \(fix)")
                //self.logs.append("\(fix)")
            }
        }).disposed(by: rxDisposeBag)
        /*tripRecorder.rxIsDriving?.asObserver().observeOn(MainScheduler.instance).subscribe({ (event) in
            if let isDriving = event.element {
                //self?.appendText(string: "\n isDriving: \n \(isDriving)")
                //self?.saveLog("\n isDriving: \n \(isDriving)")
                //self.logs = "\n isDriving: \n \(isDriving)"
                print("isDriving")
                if isDriving {
                    //self?.sendNotification("Start")
                    self.selectionDrivingState = BooleanState.True
                    //self.tripRecorder.start()
                    
                } else {
                    //self?.sendNotification("Stop")
                    self.selectionDrivingState = BooleanState.False
                    //self.tripRecorder.stop()
                }
                
            }
        }).disposed(by: rxDisposeBag)*/
        
        
        texServices.rxScore.asObserver().observeOn(MainScheduler.asyncInstance).retry().subscribe({ (event) in
            if let score = event.element {
                logs.append("NEW SCORE \(score)")
                //self?.appendText(string: "NEW SCORE \(score)")
                print("NEW SCORE \(score)")
            }
        }).disposed(by: rxDisposeBag)
            
        //self.logs = "texServices != nil"
        self.configureLog(texServices.logManager.rxLog)
        //tripRecorder.activateAutoMode()
    }
    // MARK: - Log Management
    func configureLog(_ log: PublishSubject<LogMessage>) {
        print("configureLog")
        log.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
            if let logDetail = event.element {
                print("-")
                print(logDetail.description)
                //self.logs = logDetail.description
                //self?.report(logDetail: logDetail)
            }
            
            }.disposed(by: self.rxDisposeBag)
        
        do {
            //let regex = try NSRegularExpression(pattern: ".*(TripChunk|Score|URLRequestExtension.swift|API|State).*", options: NSRegularExpression.Options.caseInsensitive)
            let regex = try NSRegularExpression(pattern: ".*(URLRequestExtension.swift|API).*", options: NSRegularExpression.Options.caseInsensitive)
//            let regex = try NSRegularExpression(pattern: ".*.*", options: NSRegularExpression.Options.caseInsensitive)
            texServices.logManager.log(regex: regex, logType: LogType.Info)
        } catch {
            //let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
            //os_log("[ViewController][configureLog] regex error %@", log: customLog, type: .error, error.localizedDescription)
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10, content: {
            //Text(userId)
            SegmentedControl(selectedSegmentIndex: $selection, items: $items)
            Text("\(selection)")
            HStack(content: {
                Text("IsDriving: \(selectionDrivingState.rawValue)")
                Picker("Trip State", selection: $selectionDrivingState) {
                    Text("False").tag(BooleanState.False)
                    Text("True").tag(BooleanState.True)
                }.pickerStyle(SegmentedPickerStyle())
            })
            HStack(content: {
                Text("Recording: \(selectionTripState.rawValue)")
                Picker("Recording State", selection: $selectionTripState) {
                    Text("False").tag(BooleanState.False)
                    Text("True").tag(BooleanState.True)
                }.pickerStyle(SegmentedPickerStyle())
            })
            Button("Get Score") {
                //RetrieveScore
                logs.append("\(String(describing: Thread.current.name))")
                print("\(String(describing: Thread.current.name))")
                print("\(String(describing: Thread.current.isMainThread))")
                
            }
            Text(logs)
        })
    }
}

struct SwiftUIViewTOTO_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            HomeViewControllerSUI(texServices: appDelegate.texServices!, tripRecorder: appDelegate.texServices!.tripRecorder!)
        }
    }
}
