class Store {
    private var dependencies: [Key: Set<Key>] = [:]
    private var state: [Key: Any] = [:]
    
    subscript<T>(_ atom: Atom<T>, reader: ReadContext = .none) -> T {
        get {
            link(key: atom.key, to: reader)
            
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
    
    func link(key: Key, to context: ReadContext) {
        switch context {
            case .observer(let context): observerDependencies[key, default: []].insert(context)
            case .state(let context): dependencies[key, default: []].insert(context)
            case .none: break
        }
    }
    
    func invalidate(key: Key) {
        for key in dependencies[key, default: []] {
            state[key] = nil
            invalidate(key: key)
        }
        
        if dependencies.keys.contains(key) {
            dependencies[key] = []
        }
        
        for observer in observerDependencies[key, default: []] {
            notify(context: observer)
        }
    }
    
    subscript<T>(_ selector: Selector<T>, reader: ReadContext = .none) -> T {
        link(key: selector.key, to: reader)
        
        if let value = state[selector.key] as? T {
            return value
        }
        
        let get = Get(reader: .state(selector.key), store: self)
        let initial = selector.getter(get)
        state[selector.key] = initial
        
        return initial
    }
    
    subscript<Id, T>(id: Id, from family: Family<Id, T>, reader: ReadContext = .none) -> T {
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
    
    private var observerDependencies: [Key: Set<ObservationContext>] = [:]
    
    class ObservationContext: Hashable {
        static func == (lhs: Store.ObservationContext, rhs: Store.ObservationContext) -> Bool {
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
        
        init(observer: @escaping (Get) -> Void) {
            self.observer = observer
        }
        
        let observer: (Get) -> Void
        
        func hash(into hasher: inout Hasher) {
            ObjectIdentifier(self).hash(into: &hasher)
        }
    }
    
    func observe(observer: @escaping (Get) -> Void) {
        let context = ObservationContext(observer: observer)
        notify(context: context)
    }
    
    func notify(context: ObservationContext) {
        // TODO: Bidirectional link
        for key in observerDependencies.keys {
            observerDependencies[key]?.remove(context)
        }
        
        let get = Get(reader: .observer(context), store: self)
        context.observer(get)
    }
}
