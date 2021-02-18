import XCTest
@testable import Recoil

struct BookKeepingApp {
    struct Library {
        static let allBooks = Family<Int, Book>(
            key: { id in Key(stringLiteral: "book-\(id)") },
            initial: { id in
                Book(
                    id: id,
                    name: "Unknown",
                    author: "Unknown")
            }
        )
        
        static let allBooksIds = Atom(key: "allBooksIds") {
            [Int]()
        }
        
        static let library = Selector(key: "library") { get in
            get(allBooksIds).map { id in get(id, from: allBooks) }
        }
    }
    
    struct Search {
        static let minLength = Atom(key: "minLength") {
            0
        }
        
        static let queryInput = Atom(key: "queryInput") {
            ""
        }
        
        static let query = Recoil.Selector<String>(key: "query") { get in
            guard get(queryInput).count > get(minLength) else { return "" }
            return get(queryInput)
        }
        
        static let foundBooks = Recoil.Selector(key: "foundBooks") { get in
            get(Library.library).filter { book in
                book.name.hasPrefix(get(query))
            }
        }
    }
}


final class RecoilTests: XCTestCase {
    func test() {
        let searchQuery = Atom(key: "searchQuery") {
            "empty"
        }
        
        let store = Store()
        
        let value = store[searchQuery]
        XCTAssertEqual("empty", value)
        store[searchQuery] = "test"
        XCTAssertEqual("test", store[searchQuery])
    }
    
    func testSelector() {
        let minLength = Atom(key: "minLength") {
            0
        }
        
        let queryInput = Atom(key: "queryInput") {
            ""
        }
        
        var counter = 0
        
        let query = Recoil.Selector<String>(key: "query") { get in
            counter += 1
            guard get(queryInput).count > get(minLength) else { return "" }
            return get(queryInput)
        }
        
        let store = Store()
        
        XCTAssertEqual(store[query], "")
        XCTAssertEqual(counter, 1)
        store[queryInput] = "te"
        
        XCTAssertEqual(store[query], "te")
        XCTAssertEqual(counter, 2)
        
        XCTAssertEqual(store[query], "te")
        XCTAssertEqual(counter, 2)
        
        store[minLength] = 3
        
        XCTAssertEqual(store[query], "")
        XCTAssertEqual(counter, 3)
        
        store[queryInput] = "test"
        store[minLength] = 2
        
        XCTAssertEqual(store[query], "test")
        XCTAssertEqual(counter, 4)
    }
    
    func testFamily() {
        let store = Store()
        
        func addBooks(books: [Book]) {
            for book in books {
                store[book.id, from: BookKeepingApp.Library.allBooks] = book
            }
            
            store[BookKeepingApp.Library.allBooksIds] = books.map(\.id)
        }
        
        addBooks(books: [
            Book(id: 0, name: "Moby Dick", author: "Mark Twen"),
            Book(id: 1, name: "Type driven developement", author: "Brady Evans")
        ])
        
        XCTAssertEqual(store[BookKeepingApp.Library.allBooksIds], [0, 1])
        
        XCTAssertEqual(store[BookKeepingApp.Search.foundBooks].count, 2)
        store[BookKeepingApp.Search.queryInput] = "Type"
        XCTAssertEqual(store[BookKeepingApp.Search.foundBooks].count, 1)
        
        store[BookKeepingApp.Search.minLength] = 5
        
        XCTAssertEqual(store[BookKeepingApp.Search.foundBooks].count, 2)
        print("end")
    }
}

struct Book {
    let id: Int
    let name: String
    let author: String
}
