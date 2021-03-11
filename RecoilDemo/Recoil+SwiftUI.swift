//
//  Wrappers.swift
//  RecoilDemo
//
//  Created by Oleksii Demedetskyi on 05.03.2021.
//

import Foundation
import Combine
import SwiftUI
import Recoil

struct RecoilStoreEnvironmentKey: EnvironmentKey {
    static let defaultValue = Store()
}

extension EnvironmentValues {
    var recoilStore: Store {
        get { self[RecoilStoreEnvironmentKey.self] }
        set { self[RecoilStoreEnvironmentKey.self] = newValue }
    }
}


@propertyWrapper
struct Atom<A: AtomProtocol>: DynamicProperty {
    var wrappedValue: A.T {
        get { value.value }
        nonmutating set { value.value = newValue }
    }
    
    var projectedValue: Binding<A.T> {
        Binding(
            get: { value.value },
            set: { value.value = $0 }
        )
    }
    
    @ObservedObject var value = Value()
    
    class Value: ObservableObject {
        let objectWillChange = ObservableObjectPublisher()
    
        @Environment(\.recoilStore) var store
        let container = Recoil.Value(A.self)
        
        private lazy var observation = store.observe {
            print("will change", A.self)
            self.objectWillChange.send()
        }.tag(String(reflecting: A.self))
        
        var value: A.T {
            get {
                return store.read(container, from: observation)
            }
            set {
                store.write(value: newValue, to: container, in: observation)
            }
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
        
        var ids: Set<F.Id> = []
        
        private lazy var observation = store.observe {
            print("will change", F.self, "for", self.ids)
            self.objectWillChange.send()
        }.tag(String(reflecting: F.self))
        
        subscript(_ id: F.Id) -> F.T {
            get {
                ids.insert(id)
                let container = Recoil.Value(F.self, id: id)
                return store.read(container, from: observation)
            }
            
            set {
                let container = Recoil.Value(F.self, id: id)
                store.write(value: newValue, to: container, in: observation)
            }
        }
    }
}

@propertyWrapper
struct Derived<D: DerivedProtocol>: DynamicProperty {
    var wrappedValue: D.T {
        value.value
    }
    
    @ObservedObject var value = Value()
    class Value: ObservableObject {
        let objectWillChange = ObservableObjectPublisher()
        @Environment(\.recoilStore) var store
        
        private lazy var observation = store.observe {
            print("will change", D.self)
            self.objectWillChange.send()
        }.tag(String(reflecting: D.self))
        
        var value: D.T {
            return store.read(Recoil.Value(D.self), from: observation)

        }
    }
}
