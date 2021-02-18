class Store {
    private var dependencies: [Key: Set<Key>] = [:]
    private var state: [Key: Any] = [:]
    
    subscript<T>(_ atom: Atom<T>, reader: Key? = nil) -> T {
        get {
            if let reader = reader {
                link(key: atom.key, to: reader)
            }
            
            if let value = state[atom.key] as? T {
                return value
            }
            
            let initial = atom.initial()
            state[atom.key] = initial
            return initial
        }
        
        set {
            state[atom.key] = newValue
            invalidate(key: atom.key)
        }
    }
    
    func link(key: Key, to reader: Key) {
        dependencies[key, default: []].insert(reader)
    }
    
    func invalidate(key: Key) {
        guard dependencies.keys.contains(key) else { return }
        for key in dependencies[key, default: []] {
            state[key] = nil
            invalidate(key: key)
        }
        
        dependencies[key] = []
    }
    
    subscript<T>(_ selector: Selector<T>, reader: Key? = nil) -> T {
        if let reader = reader {
            link(key: selector.key, to: reader)
        }
        
        if let value = state[selector.key] as? T {
            return value
        }
        
        let get = Get(reader: selector.key, store: self)
        let initial = selector.getter(get)
        state[selector.key] = initial
        
        return initial
    }
    
    subscript<Id, T>(id: Id, from family: Family<Id, T>, reader: Key? = nil) -> T {
        get {
            let atom = Atom(key: family.key(id)) {
                family.initial(id)
            }
            
            return self[atom, reader]
        }
        set {
            let atom = Atom(key: family.key(id)) {
                family.initial(id)
            }
            
            self[atom, reader] = newValue
        }
    }
}
