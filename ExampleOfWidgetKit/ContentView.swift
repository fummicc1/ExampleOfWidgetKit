//
//  ContentView.swift
//  ExampleOfWidgetKit
//
//  Created by Fumiya Tanaka on 2020/10/12.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.due, ascending: true)],
        animation: .default)
    private var todos: FetchedResults<Todo>
    
    @State private var isShowingAddTodoView: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(todos) { (todo: Todo) in
                    VStack {
                        Text(todo.task!).font(.title)
                        Text("Todo at \(todo.due!, formatter: todoDateFormatter)")
                    }
                }
                .onDelete(perform: deleteTodos)
            }
            .navigationTitle("Todo List")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    #if os(iOS)
                    EditButton()
                    #endif

                    Button(action: showAddTodoView) {
                        Label("Add Todo", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddTodoView) {
                AddTodoView().environment(\.managedObjectContext, viewContext)
            }            
        }
    }
    
    private func showAddTodoView() {
        isShowingAddTodoView = true
    }

    private func deleteTodos(offsets: IndexSet) {
        withAnimation {
            offsets.map { todos[$0] }.forEach(viewContext.delete)

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

private let todoDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
