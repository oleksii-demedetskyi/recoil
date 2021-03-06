
import Foundation
public indirect enum Key: Hashable {
    case title(String)
    case child(family: Key, id: AnyHashable)
}

public struct Atom<T> {
    public init(key: Key = .title(#function), initial: @escaping () -> T) {
        self.key = key
        self.initial = initial
    }
    
    let key: Key
    let initial: () -> T
}

