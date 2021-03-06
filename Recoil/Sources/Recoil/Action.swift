//
//  File.swift
//  
//
//  Created by Oleksii Demedetskyi on 05.03.2021.
//

public struct Setter {
    let store: Store
    
    public func callAsFunction<T, Id>(_ value: T, to id: Id, in family: Family<Id, T>) where Id: Hashable {
        store[family[id]] = value
    }
    
    public func callAsFunction<T>(_ value: T, to atom: Atom<T>) {
        store[atom] = value
    }
}

public struct Action{
    let execute: (Store) -> Void
    public init(execute: @escaping (Store) -> Void) {
        self.execute = execute
    }
}
