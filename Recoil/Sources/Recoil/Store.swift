

enum ReadContext {
    case derived(Key)
    case observation(Observation)
    case global
}

public class Store {
    public init() {}
    
    private var dependencies: [Key: Set<Key>] = [:] {
        didSet {
            //traceDependencies()
        }
        
    }
    private var observers: [Key: Set<Observation>] = [:] {
        didSet {
            //traceObservers()
        }
    }
    private var state: [Key: Any] = [:] {
        didSet {
            traceState()
        }
    }
    
    func read<T>(_ container: Value<T>, from context: ReadContext) -> T {
        link(key: container.key, to: context)
        
        if let value = state[container.key] as? T {
            return value
        }
        
        let reader = ReadableState(context: .derived(container.key), store: self)
        let initial = container.initial(reader)
        state[container.key] = initial
        return initial
    }
    
    func write<T>(value: T, to container: Value<T>, in context: ReadContext) {
        state[container.key] = value
        invalidate(key: container.key, in: &dependencies)
        eraseInvalidatedContexts()
    }
        
    func link(key: Key, to context: ReadContext) {
        switch context {
            case .derived(let context): dependencies[key, default: []].insert(context)
            case .observation(let context):
                context.ready() // Marks context as valid and ready to accept changes
                observers[key, default: []].insert(context)
            case .global: break
        }
    }
    
    func invalidate(key: Key, in dependencies: inout [Key: Set<Key>]) {
        for upstream in dependencies.keys {
            dependencies[upstream]?.remove(key)
        }
        
        for key in dependencies[key, default: []] {
            state[key] = nil
            invalidate(key: key, in: &dependencies)
        }
        
        if dependencies.keys.contains(key) {
            dependencies[key] = []
        }
        
        for (key, deps) in dependencies {
            if deps.isEmpty {
                dependencies[key] = nil
            }
        }
        
        for context in observers[key, default: []] {
            context.invalidateIfNeeded()
        }
    }
    
    func eraseInvalidatedContexts() {
        for (key, value) in observers {
            observers[key] = value.filter { context in context.invalidated }
        }
    }
}

public class Observation {
    private(set) var invalidated: Bool = false
    private let invalidate: () -> ()
    public init(invalidate: @escaping () -> ()) {
        self.invalidate = invalidate
    }
    
    func invalidateIfNeeded() {
        guard invalidated == false else { return }
        self.invalidated = true
        self.invalidate()
    }
    
    func ready() {
        invalidated = false
    }
    
    var name: String?
}

extension Observation: Hashable {
    public static func == (lhs: Observation, rhs: Observation) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
    
    public func tag(_ name: String) -> Self {
        self.name = name
        return self
    }
}

extension Store {
    
    public func observe(invalidate: @escaping () -> ()) -> Observation {
        Observation(invalidate: invalidate)
    }
    
    public func read<T>(_ container: Value<T>, from context: Observation) -> T {
        read(container, from: .observation(context))
    }
    
    public func write<T>(value: T, to container: Value<T>, in context: Observation) {
        write(value: value, to: container, in: .observation(context))
    }
}

extension Store {
    func traceDependencies() {
        if dependencies.isEmpty { return }
        //debugPrint(dependencies)
        print("Dependencies graph")
        for key in dependencies.keys {
            print("| \(key) ->")
            for value in dependencies[key, default: []] {
                print("|     \(value)")
            }
        }
        print("----")
        print("")
    }
    
    func traceObservers() {
        if observers.isEmpty { return }
        
        print("Observers graph")
        for key in observers.keys {
            print("| \(key) ->")
            for value in observers[key, default: []] {
                print("|     \(value.name ?? "<unknown")")
            }
        }
        print("----")
        print("")
    }
    
    func traceState() {
        print("State graph")
        for (key, value) in state {
            print("| \(key) -> \(value)")
        }
        print("----")
        print("")
    }
}
