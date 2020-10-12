//
//  AddTodoViewModel.swift
//  ExampleOfWidgetKit
//
//  Created by Fumiya Tanaka on 2020/10/12.
//

import SwiftUI
import Combine
import CoreData

class AddTodoViewModel: ObservableObject {
    @Published var task: String = ""
    @Published var due: Date = Date()
    @Published var errorMessage: String?
    @Published var completeSavingTask: Bool = false
    
    let context: NSManagedObjectContext
    var cancellables: Set<AnyCancellable> = []
    
    init(context: NSManagedObjectContext, presenting: Binding<Bool>) {
        self.context = context
        $completeSavingTask.sink(receiveValue: { complete in
            if complete {
                presenting.wrappedValue = false
            }
        })
        .store(in: &cancellables)
    }
    
    func save() {
        if task.isEmpty {
            errorMessage = "Please input all columns."
            return
        }
        withAnimation {
            let todo = Todo(context: context)
            todo.due = due
            todo.task = task

            do {
                try context.save()
                errorMessage = nil
                completeSavingTask = true
            } catch {
                errorMessage = "\(error)"
            }
        }
    }
}
