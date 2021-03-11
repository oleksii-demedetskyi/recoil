
import Foundation

public protocol AtomProtocol {
    associatedtype T: Codable
    static var initial: T { get }
}

extension Value {
    public init<A: AtomProtocol>(_ atom: A.Type) where T == A.T {
        key = .atom(type: String(reflecting: atom))
        initial = { _ in atom.initial }
    }
}
