//
//  ContentView.swift
//  inoutExample
//
//  Created by Jason Rich Darmawan Onggo Putra on 01/07/23.
//

import SwiftUI

class ChildViewModel: ObservableObject {
    @Published var childM: [ParentModel]
    
    // `inout` acts as if the value was copied in at the time it was passed into the call,
    // and copied out (overwriting the original) at the end of the call.
    // The changes in self.childM will not reflect ParentViewModel.parentM and vice versa.
    init(childM: inout [ParentModel]) {
        // self.childM = childM is not a reference but a copy.
        self.childM = childM
        childM.append(ParentModel(name: "3child"))
        
        print("\(type(of: self)) \(#function)")
    }
}

struct ChildView: View {
    @ObservedObject var childVM: ChildViewModel
    
    init(childVM: ChildViewModel) {
        self.childVM = childVM
        print("\(type(of: self)) \(#function)")
    }
    
    var body: some View {
        ForEach(childVM.childM.indices, id: \.self) { index in
            Text(childVM.childM[index].name)
        }
        .onAppear {
            print("\(type(of: self)) \(#function) appeared")
        }
        .onDisappear {
            print("\(type(of: self)) \(#function) disappeared")
        }
    }
}

struct ParentModel {
    var name: String
}

class ParentViewModel: ObservableObject {
    @Published var parentM: [ParentModel] = []
    
    var childVM: ChildViewModel
    
    init() {
        var tempData: [ParentModel] = []
        
        //
        tempData.append(ParentModel(name: "1"))
        childVM = ChildViewModel(childM: &tempData)
        tempData.append(ParentModel(name: "2"))
        
        self.parentM = tempData
        print("\(type(of: self)) \(#function)")
    }
}

struct ParentView: View {
    @StateObject var parentVM: ParentViewModel
    
    init() {
        let parentVM = ParentViewModel()
        parentVM.parentM.append(ParentModel(name: "3parent"))
        
        _parentVM = StateObject(wrappedValue: parentVM)
        
        // Accessing StateObject's object without being installed on a View.
        // This will create a new instance each time.
        // The changes in the init() method of ParentView do not immediately reflect in self.parentVM.parentM
        // because the initialization of the StateObject wrapped value occurs synchronously,
        // meaning that any modifications made to self.parentVM.parentM in the init() method will not be observable
        // until after the ParentView has been fully initialized.
//        self.parentVM.parentM.append(ParentModel(name: "4parent"))
        
        print("\(type(of: self)) \(#function)")
    }
    
    var body: some View {
        VStack {
            Text("ParentView")
            Button("Add to ParentViewModel") {
                // https://stackoverflow.com/a/68390850/13285583
                // ParentView should not have StateObject.
                // The changes in the parentVM will re-render ChildView.
                // Structure your views so that each view displays a single level of the object structure,
                // matching views to the classes that conform to `ObservableObject`.
//                parentVM.parentM.append(ParentModel(name: "4parent"))
            }
            ForEach(parentVM.parentM.indices, id: \.self) { index in
                Text(parentVM.parentM[index].name)
            }
            
            Text("ChildView")
            Button("Add to ChildViewModel") {
                parentVM.childVM.childM.append(ParentModel(name: "4child"))
            }
            ChildView(childVM: parentVM.childVM)
        }
        .onAppear {
            print("\(type(of: self)) \(#function) appeared")
        }
        .onDisappear {
            print("\(type(of: self)) \(#function) disappeared")
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            ParentView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
