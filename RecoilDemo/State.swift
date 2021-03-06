import SwiftUI

struct LibraryState: DynamicProperty {
    struct Book {
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
    
    struct NextBookId: AtomProtocol {
        static let initial: Int = 0
    }

    struct AllBooksIds: AtomProtocol {
        static let initial: [Int] = []
    }
    
    @Atom<NextBookId> private var nextBookId
    @Atom<AllBooksIds> private var allBooksIds
    
    @Family<AllBooks> private var allBooks
    
    func addBook(title: String, author: String) {
        let id = nextBookId
        nextBookId += 1
        
        allBooks[id] = Book(id: id, name: title, author: author)
        allBooksIds.append(id)
    }
    
    var books: [BookState] {
        allBooksIds.map { id in
            BookState(id: id)
        }
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
