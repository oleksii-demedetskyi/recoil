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
        VStack {
            Picker("", selection: library.$category) {
                Text("All").tag(LibraryState.Category.all)
                Text("Favorites").tag(LibraryState.Category.favorites)
            }
            .pickerStyle(SegmentedPickerStyle())

            List(library.books) { book in
                BookView(book: book)
            }
            
            TextField("Name", text: newBookState.$name)
            TextField("Author", text: newBookState.$author)
            
            Button("Add") { newBookState.add() }
                .disabled(!newBookState.canAddBook)
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
        LibraryView().onAppear {
            let newBook = NewBookState()
            newBook.author = "Test"
            newBook.name = "Some name"
            newBook.add()
        }
    }
}
