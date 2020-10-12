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
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(todos) { (todo: Todo) in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(todo.task!).font(.title3)
                            Text("Todo at \(todo.due!, formatter: todoDateFormatter)")
                        }
                    }
                    .onDelete(perform: deleteTodos)
                }
                Button(action: showAddTodoView) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Circle())
                .shadow(color: .gray, radius: 2, x: 2, y: 2)
                .alignmentGuide(.bottom, computeValue: { dimension in
                    dimension[.bottom] + 40
                })
                .alignmentGuide(.trailing, computeValue: { dimension in
                    dimension[.trailing] + 24
                })
            }
            .navigationTitle("Todo List")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    #if os(iOS)
                    EditButton()
                    #endif
                }
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button(action: deleteAll, label: {
                        HStack(spacing: 4) {
                            Text("Delete All")
                            Image(systemName: "trash")
                        }
                    })
                }
            }
            .sheet(isPresented: $isShowingAddTodoView) {
                AddTodoView(viewContext: viewContext, presenting: $isShowingAddTodoView)
            }            
        }
    }
    
    private func deleteAll() {
        todos.forEach(viewContext.delete)
        try? viewContext.save()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
