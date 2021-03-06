public struct Family<Id: Hashable, T> {
    public init(_ key: Key = .title(#function), initial: @escaping (Id) -> T) {
        self.key = key
        self.initial = initial
    }
    
    let key: Key
    let initial: (Id) -> T
    
    public subscript(_ id: Id) -> Atom<T> {
        Atom(key: .child(family: key, id: id)) {
            initial(id)
        }
    }
}
