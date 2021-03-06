enum ReadContext {
    case derived(Key)
    case global
}

public struct Reader {
    let context: ReadContext
    var store: Store
    
    public func callAsFunction<T>(_ atom: Atom<T>) -> T {
        store[atom, context]
    }
    
    
    public func callAsFunction<T>(_ derived: Derived<T>) -> T {
        store[derived, context]
    }
}

public struct Derived<T> {
    public init(key: Key, initial: @escaping (Reader) -> T) {
        self.key = key
        self.initial = initial
    }
    
    let key: Key
    let initial: (Reader) -> T
}
