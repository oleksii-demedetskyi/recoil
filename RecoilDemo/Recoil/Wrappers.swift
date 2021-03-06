//
//  Wrappers.swift
//  RecoilDemo
//
//  Created by Oleksii Demedetskyi on 05.03.2021.
//

import Foundation
import Combine
import SwiftUI
// import Recoil

//class Source<T>: ObservableObject {
//    @Environment(\.recoilStore) var store
//    let objectWillChange = ObservableObjectPublisher()
//    var observation: Store.Observation?
//    let valueProvider: (Source) -> T
//
//    var value: T {
//        valueProvider(self)
//    }
//
//    init(atom: Atom<T>) {
//        self.valueProvider = { source in
//            if source.observation == nil {
//                source.observation = source.store.observe(atom, willChange: source.willChange)
//            }
//            return source.store[atom]
//        }
//    }
//
//    init(derived: Derived<T>) {
//        self.valueProvider = { source in
//            if source.observation == nil {
//                source.observation = source.store.observe(derived, willChange: source.willChange)
//            }
//            return source.store[derived]
//        }
//    }
//
//    func willChange() {
//        print("will change")
//        objectWillChange.send()
//    }
//}
//
//@propertyWrapper
//public struct RecValue<T>: DynamicProperty {
//    @ObservedObject private var source: Source<T>
//
//    public init(_ derived: Derived<T>) {
//        self.source = Source(derived: derived)
//    }
//
//    public init(_ atom: Atom<T>) {
//        self.source = Source(atom: atom)
//    }
//
//    public var wrappedValue: T {
//        get {
//            print("get")
//            return source.value
//        }
//    }
//}

//@propertyWrapper
//struct RecRun {
//    @Environment(\.recoilStore) var store
//    var wrappedValue: (() -> Action) -> () {
//        { actionCreator in
//            store.call(actionCreator())
//        }
//    }
// }


protocol AtomProtocol {
    associatedtype T
    static var initial: T { get }
}

protocol FamilyProtocol {
    associatedtype T
    associatedtype Id: Hashable
    static func initial(id: Id) -> T
}


import Recoil

@propertyWrapper
struct Atom<A: AtomProtocol>: DynamicProperty {
    var wrappedValue: A.T {
        get { value.value }
        nonmutating set { value.value = newValue }
    }
    
    @ObservedObject var value = Value()
    
    class Value: ObservableObject {
        let objectWillChange = ObservableObjectPublisher()
    
        @Environment(\.recoilStore) var store
        let atom = Recoil.Atom(key: .title(String(reflecting: A.self)), initial: { A.initial })
        
        var observation: Recoil.Store.Observation?
        
        var value: A.T {
            get {
                observation = store.observe(atom, willChange: willChange)
                return store[atom]
            }
            set {
                store[atom] = newValue
            }
        }
        
        func willChange() {
            print("will change", A.self)
            objectWillChange.send()
        }
    }
}

@propertyWrapper
struct Family<F: FamilyProtocol>: DynamicProperty {
    var wrappedValue: Value { value }
    @ObservedObject var value = Value()
    
    class Value: ObservableObject {
        let objectWillChange = ObservableObjectPublisher()
        @Environment(\.recoilStore) var store
        let family = Recoil.Family(.title(String(reflecting: F.self)), initial: F.initial(id:))
        
        var observations: [Recoil.Store.Observation] = []
        
        subscript(_ id: F.Id) -> F.T {
            get {
                observations.append(store.observe(family[id], willChange: willChange))
                return store[family[id]]
            }
            
            set {
                store[family[id]] = newValue
            }
        }
        
        func willChange() {
            print("will change", F.self)
            objectWillChange.send()
        }
    }
}
