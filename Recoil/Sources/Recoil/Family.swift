public protocol FamilyProtocol {
    associatedtype T: Codable
    associatedtype Id: Hashable
    static func initial(id: Id) -> T
}

extension Value {
    public init<F: FamilyProtocol>(_ family: F.Type, id: F.Id) where F.T == T {
        key = .family(type: String(reflecting: family), id: id)
        initial = { _ in F.initial(id: id) }
    }
}

extension FamilyProtocol {
    public static subscript(_ id: Id) -> Value<T> {
        Value(self, id: id)
    }
}
