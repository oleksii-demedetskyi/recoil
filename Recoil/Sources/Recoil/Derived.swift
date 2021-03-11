public protocol DerivedProtocol {
    associatedtype T: Codable
    static func derive(from state: ReadableState) -> T
}

extension Value {
    public init<D: DerivedProtocol>(_ derived: D.Type) where T == D.T {
        key = .derived(type: String(reflecting: derived))
        initial = { D.derive(from: $0) }
    }
}


public struct ReadableState {
    let context: ReadContext
    var store: Store
    
    public subscript<A: AtomProtocol>(_ atom: A.Type) -> A.T {
        self[Value(atom)]
    }
    
    public subscript<T>(_ value: Value<T>) -> T {
        store.read(value, from: context)
    }
}
