public extension Store {
    subscript<T>(_ atom: Atom<T>) -> T {
        get { self[atom, .global] }
        set { self[atom, .global] = newValue }
    }
    
    subscript<T>(_ derived: Derived<T>) -> T {
        get { self[derived, .global] }
    }
}

public class Store {
    public init() {}
    
    private var dependencies: [Key: Set<Key>] = [:]
    private var state: [Key: Any] = [:] {
        didSet {
            print("Updated to", state)
        }
    }
    
    subscript<T>(_ atom: Atom<T>, reader: ReadContext = .global) -> T {
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
            case .derived(let context): dependencies[key, default: []].insert(context)
            case .global: break
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
        
        for container in observations[key, default: []] {
            container.observation?.willChange()
        }
    }
    
    subscript<T>(_ selector: Derived<T>, reader: ReadContext = .global) -> T {
        link(key: selector.key, to: reader)
        
        if let value = state[selector.key] as? T {
            return value
        }
        
        let reader = Reader(context: .derived(selector.key), store: self)
        let initial = selector.initial(reader)
        state[selector.key] = initial
        
        return initial
    }
    
    public class ObservationContainer {
        weak var observation: Observation?
        
        init(observation: Observation) {
            self.observation = observation
        }
    }
    
    public class Observation {
        let willChange: () -> ()
        init(willChange: @escaping () -> ()) {
            self.willChange = willChange
        }
    }
    
    private var observations: [Key: [ObservationContainer]] = [:]
    
    public func observe(_ key: Key, willChange: @escaping () -> ()) -> Observation {
        let observation = Observation(willChange: willChange)
        let container = ObservationContainer(observation: observation)
        observations[key, default: []].append(container)
        
        return observation
    }
    
    public func observe<T>(_ atom: Atom<T>, willChange: @escaping () -> ()) -> Observation {
        observe(atom.key, willChange: willChange)
    }
    
    public func observe<T>(_ derived: Derived<T>, willChange: @escaping () -> ()) -> Observation {
        observe(derived.key, willChange: willChange)
    }
    
    public func call(_ action: Action) {
        action.execute(self)
    }
}
