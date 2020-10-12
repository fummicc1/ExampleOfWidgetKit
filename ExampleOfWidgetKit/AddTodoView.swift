//
//  AddTodoView.swift
//  ExampleOfWidgetKit
//
//  Created by Fumiya Tanaka on 2020/10/12.
//

import SwiftUI

struct AddTodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            
        }.toolbar {
            Button(action: addItem) {
                #if os(iOS)
                EditButton()
                #endif
                Label("Add Item", systemImage: "plus")
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Todo(context: viewContext)
            newItem.due = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddTodoView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoView()
    }
}
