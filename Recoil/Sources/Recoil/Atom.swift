
import Foundation
struct Key: Hashable, ExpressibleByStringLiteral {
    let id: String
    init(stringLiteral value: String) {
        id = value
    }
}

struct Atom<T> {
    let key: Key
    let initial: () -> T
}

