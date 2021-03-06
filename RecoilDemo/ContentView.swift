//
//  ContentView.swift
//  RecoilDemo
//
//  Created by Oleksii Demedetskyi on 17.02.2021.
//

import SwiftUI

struct LibraryView: View {
    let library = LibraryState()
    
    var body: some View {
        Button("Add") {
            library.addBook(title: "Text", author: "Auth")
        }
        
        List(library.books) { book in
            BookView(book: book)
        }
    }
}

struct BookView: View {
    let book: BookState
    
    var body: some View {
        Image(systemName: "star.fill")
            .foregroundColor(book.isFavorite ? .yellow : .gray)
            .onTapGesture { book.isFavorite.toggle() }
        
        Text("\(book.name) by \(book.author)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
