//
//  SegmentedControl.swift
//  TexDriveApp
//
//  Created by Erwan Masson on 06/10/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import SwiftUI
struct SegmentedControl: UIViewRepresentable {

    
    class Coordinator: NSObject {
        var parent: SegmentedControl
        init(segmentedControl: SegmentedControl) {
            parent = segmentedControl
        }
        
        @objc func selectedIndexChanged(_ sender: UISegmentedControl) {
            self.parent.selectedSegmentIndex = sender.selectedSegmentIndex
        }
    }
    
    @Binding var selectedSegmentIndex: Int
    @Binding var items: [String]
    typealias UIViewType = UISegmentedControl
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
        segmentedControl.addTarget(context.coordinator, action: #selector(Coordinator.selectedIndexChanged(_:)), for: UIControl.Event.primaryActionTriggered)
        return segmentedControl
    }
    
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
       uiView.selectedSegmentIndex = self.selectedSegmentIndex
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(segmentedControl: self)
    }
}

enum BooleanState: String, CaseIterable, Identifiable {
    case False
    case True

    var id: String { self.rawValue }
}

struct TestSegmentedControl: View {
    @State var selection = 0
    @State var selectionDrivingState = BooleanState.False
    @State var selectionTripState = BooleanState.False
    @State var items = ["On1", "Off"]
    
    var body: some View {
        VStack(alignment: .center, spacing: 10, content: {
            
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
            }
        })
    }
}


struct SegmentedControl_Previews: PreviewProvider {
    
    
    static var previews: some View {
        Group {
            TestSegmentedControl()
        }
    }
}
