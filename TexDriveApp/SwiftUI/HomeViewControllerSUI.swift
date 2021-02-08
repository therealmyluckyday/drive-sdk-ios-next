//
//  SwiftUIViewTOTO.swift
//  TexDriveApp
//
//  Created by Erwan Masson on 02/10/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

#if canImport(Swiftui)
import SwiftUI
import TexDriveSDK
import RxSwift
import Combine


@available(iOS 13, *)
struct HomeViewControllerSUI: View {
    let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
    @ObservedObject var tripRecorder: TexDriveSDK.TripRecorderiOS13SwiftUI
    @ObservedObject var texServices: TexDriveSDK.TexServicesiOS13SwiftUI
    @State var selectionDrivingState = BooleanState.False
    @State var selectionTripState = BooleanState.False
    @State var items = ["On1", "Off"]
    
    var body: some View {
        VStack(alignment: .center, spacing: 10, content: {
            HStack(content: {
                Text("IsDriving: ")
                Picker("Trip State", selection: $selectionDrivingState) {
                    Text("False").tag(BooleanState.False)
                    Text("True").tag(BooleanState.True)
                }.pickerStyle(SegmentedPickerStyle())
            })
            HStack(content: {
                Text("Recording: ")
                Picker("Recording State", selection: $selectionTripState) {
                    Text("False").tag(BooleanState.False)
                    Text("True").tag(BooleanState.True)
                }.pickerStyle(SegmentedPickerStyle())
            })
            Button("Get Score") {
                //RetrieveScore
                //logs.append("\(String(describing: Thread.current.name))")
                print("\(String(describing: Thread.current.name))")
                print("\(String(describing: Thread.current.isMainThread))")
                
            }
            Text("---")
            Text(texServices.logiOS13)
            
        })
        .onReceive(texServices.tripRecorderiOS13.$isRecordingiOS13) { value in
            DispatchQueue.main.async {
                sendNotification("isRecording \(value)")
                self.selectionTripState = value ? BooleanState.True : BooleanState.False
            }
        }
        .onReceive(texServices.tripRecorderiOS13.$isDrivingiOS13) { value in
            DispatchQueue.main.async {
                sendNotification("isDriving \(value)")
                self.selectionDrivingState = value ? BooleanState.True : BooleanState.False
            }
        }
    }
}
 
@available(iOS 13, *)
struct SwiftUIViewTOTO_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let texService = appDelegate.texServices as! TexServicesiOS13SwiftUI
            let tripRecorder = texService.tripRecorderiOS13
            HomeViewControllerSUI(tripRecorder: tripRecorder, texServices: texService)
        }
    }
}
extension HomeViewControllerSUI {
    
func sendNotification(_ text: String) {
    // Configure the notification's payload.
    let content = UNMutableNotificationContent()
    content.title = "AutoMode"
    content.body = text
    content.sound = UNNotificationSound.default
    
    // Deliver the notification in x seconds.
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(10), repeats: false)
    let request = UNNotificationRequest(identifier: "AutoMode"+text, content: content, trigger: trigger) // Schedule the notification.
    let center = UNUserNotificationCenter.current()
    
    center.add(request) { (error : Error?) in
    }
}
    
}


#endif
