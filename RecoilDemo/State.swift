import SwiftUI
import Recoil

struct LibraryState: DynamicProperty {
    struct Book: Codable {
        let id: Int
        var name: String = "Unknown"
        var author: String = "Unknown"
        var isFavorite: Bool = false
    }
    
    struct AllBooks: FamilyProtocol {
        static func initial(id: Int) -> Book {
            Book(id: id)
        }
    }

    struct AllBooksIds: AtomProtocol {
        static let initial: [Int] = []
    }
    
    enum Section: String, Codable, Hashable, AtomProtocol {
        static let initial = Self.all
        
        case all
        case favorites
    }
    
    struct ActiveBookIds: DerivedProtocol {
        static func derive(from state: ReadableState) -> [Int] {
            switch state[Section] {
                case .all: return state[AllBooksIds]
                case .favorites: return state[AllBooksIds].filter { id in
                    state[AllBooks[id]].isFavorite
                }
            }
        }
    }
    
    struct SearchQuery: AtomProtocol {
        static let initial = ""
    }
    
    @Atom<AllBooksIds> private var allBooksIds
    @Family<AllBooks> private var allBooks
    
    @Atom<SearchQuery> var query
    
    @Atom<Section> var section
        
    var booksIds: [Int] {
        switch section {
            case .all: return allBooksIds
            case .favorites: return allBooksIds.filter { id in allBooks[id].isFavorite }
        }
    }
    
    @Derived<ActiveBookIds> var activeBooksIds
    
    var books: [BookState] {
        activeBooksIds.map(BookState.init)
    }
}

struct BookState: Identifiable, DynamicProperty {
    let id: Int
    
    @Family<LibraryState.AllBooks> private var allBooks
    
    var name: String { allBooks[id].name }
    var author: String { allBooks[id].author }
    
    var isFavorite: Bool {
        get { allBooks[id].isFavorite }
        nonmutating set {
            allBooks[id].isFavorite = newValue
        }
    }
}

struct NewBookState: DynamicProperty {
    struct Author: AtomProtocol {
        static let initial = ""
    }
    
    struct Name: AtomProtocol {
        static let initial = ""
    }
    
    struct NextBookId: AtomProtocol {
        static let initial: Int = 0
    }
    
    struct CanAddBook: DerivedProtocol {
        static func derive(from state: ReadableState) -> Bool {
            state[Author].count > 1 && state[Name].count > 1
        }
    }
    
    @Atom<Author> var author
    @Atom<Name> var name
    @Atom<NextBookId> private var nextBookId
    
    @Family<LibraryState.AllBooks> private var allBooks
    @Atom<LibraryState.AllBooksIds> private var allBooksIds
    
    @Derived<CanAddBook> var canAddBook
    
    @Atom<LibraryState.Section> var currentSection
    
    func addBook() {
        let id = nextBookId
        nextBookId += 1
        
        allBooks[id] = LibraryState.Book(id: id, name: name, author: author, isFavorite: currentSection == .favorites)
        allBooksIds.append(id)
        
        author = ""
        name = ""
    }
}
