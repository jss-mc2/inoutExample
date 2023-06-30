# Important

1. ParentView should not have StateObject.

The changes in the parentVM will re-render ChildView.

Structure your views so that each view displays a single level of the object structure, matching views to the classes that conform to `ObservableObject`.

```swift
            Button("Add to ParentViewModel") {
                // https://stackoverflow.com/a/68390850/13285583
                // ParentView should not have StateObject.
                // The changes in the parentVM will re-render ChildView.
//                parentVM.parentM.append(ParentModel(name: "4parent"))
            }
```

2. Accessing StateObject's object without being installed on a View. This will create a new instance each time.

The changes in the init() method of ParentView do not immediately reflect in self.parentVM.parentM because the initialization of the StateObject wrapped value occurs synchronously, meaning that any modifications made to self.parentVM.parentM in the init() method will not be observable until after the ParentView has been fully initialized.

```swift
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
```

3. `inout` acts as if the value was copied in at the time it was passed into the call, and copied out (overwriting the original) at the end of the call. 

The changes in self.childM will not reflect ParentViewModel.parentM and vice versa.
```swift
    init(childM: inout [ParentModel]) {
        // self.childM = childM is not a reference but a copy.
        self.childM = childM
        childM.append(ParentModel(name: "3child"))
        
        print("\(type(of: self)) \(#function)")
    }
```
