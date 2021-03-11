import SwiftUI
import Recoil

struct LibraryState: DynamicProperty {
    struct Book: Codable {
        let id: Int
        var name: String = "Unknown"
        var author: String = "Unknown"
        var isFavorite: Bool = false
    }
}
