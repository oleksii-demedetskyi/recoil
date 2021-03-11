//
//  ContentView.swift
//  RecoilDemo
//
//  Created by Oleksii Demedetskyi on 17.02.2021.
//

import SwiftUI

struct LibraryView: View {
    let library = LibraryState()
    let newBookState = NewBookState()
    
    var body: some View {
        TextField("Search", text: library.$query)
        
        Picker("Section", selection: library.$section) {
            Text("All").tag(LibraryState.Section.all)
            Text("Favorites").tag(LibraryState.Section.favorites)
        }
        .pickerStyle(SegmentedPickerStyle())
        
        List(library.books) { book in
            BookView(book: book)
        }
        
        Button("Add") { newBookState.addBook() }
            .disabled(!newBookState.canAddBook)
        
        TextField("Name", text: newBookState.$name)
        TextField("Author", text: newBookState.$author)
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
