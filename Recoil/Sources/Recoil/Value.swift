//
//  File.swift
//  
//
//  Created by Oleksii Demedetskyi on 10.03.2021.
//

public struct Value<T> {
    let key: Key
    let initial: (ReadableState) -> T
}
