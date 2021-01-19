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
import Combine


/*sub2 = texServicesiOS13.$log
    .receive(on: RunLoop.main)
    .sink(receiveCompletion: {
            print ("2 SUB completion: \($0)")
        
    },
    receiveValue: { print ("2 SUB receiveValue: \($0)") }
    )*/

/*tripRecorderiOS13.$isRecordingiOS13.receive(on: RunLoop.main)
    .map( {
        print ("SUB isRecordingiOS13: \($0)")
    let bool = ($0 as Bool)
    return bool ? BooleanState.True : BooleanState.False
})
    .receive(on: RunLoop.main)
    .assign(to: \.selectionTripState, on: self)
    .store(in: &cancellableBag)*/
    
/*sink(receiveCompletion: {
                                                    print ("1 SUB Completion: \($0)")
    
},
          receiveValue: {
            print ("1 SUB receiveValue: \($0)")
            
          })*/
//self.configureTexSDK(withUserId: userId)

//selectionTripState = tripRecorderiOS13.isRecordingiOS13 assign(to: \.text, on: self.label)


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
                self.selectionTripState = value ? BooleanState.True : BooleanState.False
            }
        }
        .onReceive(texServices.tripRecorderiOS13.$isDrivingiOS13) { value in
            DispatchQueue.main.async {
                self.selectionDrivingState = value ? BooleanState.True : BooleanState.False
            }
        }
    }
}

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
