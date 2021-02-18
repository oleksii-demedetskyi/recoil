struct Get {
    let reader: Key
    var store: Store
    
    func callAsFunction<T>(_ atom: Atom<T>) -> T {
        store[atom, self.reader]
    }
    
    func callAsFunction<Id, T>(_ id: Id, from family: Family<Id, T>) -> T {
        store[id, from: family, self.reader]
    }
    
    func callAsFunction<T>(_ selector: Selector<T>) -> T {
        store[selector, self.reader]
    }
}

struct Selector<T> {
    let key: Key
    let getter: (Get) -> T
}
