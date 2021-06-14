import SwiftUI
import Autocore

struct LibraryState: DynamicProperty {
    
    struct Book: Codable {
        let id: Int
        var name: String = "Unknown"
        var author: String = "Unknown"
        var isFavorite: Bool = false
    }
    
    struct AllBooks: FamilyDefinition {
        static func initial(id: Int) -> Book { Book(id: id) }
    }
    
    struct AllBooksIds: AtomDefinition {
        static let initial: [Int] = []
    }
    
    enum Category: String, Codable, AtomDefinition {
        static var initial = Self.all
        
        case all
        case favorites
    }
    
    struct VisibleBooks: DerivedValueDefinition {
        static func derive(from state: ReadableState) -> [Int] {
            switch state[Category] {
                case .all: return state[AllBooksIds]
                case .favorites: return state[AllBooksIds].filter { id in state[AllBooks[id]].isFavorite }
            }
        }
    }
    
    @Atom<AllBooksIds> var ids
    @Family<AllBooks> var allBooks
    @Atom<Category> var category
    @Derived<VisibleBooks> var visibleIds
    
    var books: [BookState] {
        visibleIds.map { id in BookState(id: id) }
    }
}

struct BookState: Identifiable, DynamicProperty {
    let id: Int
    
    @Family<LibraryState.AllBooks> var allBooks
    
    var name: String { allBooks[id].name }
    var author: String { allBooks[id].author }
    
    var isFavorite: Bool {
        get { allBooks[id].isFavorite }
        nonmutating set { allBooks[id].isFavorite = newValue }
    }
}

struct NewBookState: DynamicProperty {
    struct Author: AtomDefinition {
        static let initial = ""
    }
    
    struct Name: AtomDefinition {
        static let initial = ""
    }
    
    private struct NextBookId: AtomDefinition {
        static let initial = 0
    }
    
    @Atom<Author> var author
    @Atom<Name> var name
    @Atom<NextBookId> private var nextId
    @Atom<LibraryState.AllBooksIds> var allBooksIds
    @Family<LibraryState.AllBooks> var allBooks
    
    var canAddBook: Bool {
        author.count > 2 && name.count > 2
    }
    
    func add() {
        let id = nextId
        nextId += 1
        
        allBooks[id] = LibraryState.Book(id: id, name: name, author: author)
        allBooksIds.append(id)
        
        author = ""
        name = ""
    }
}
