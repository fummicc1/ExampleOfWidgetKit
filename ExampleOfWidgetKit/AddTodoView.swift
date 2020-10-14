//
//  AddTodoView.swift
//  ExampleOfWidgetKit
//
//  Created by Fumiya Tanaka on 2020/10/12.
//

import SwiftUI
import CoreData
import Combine

struct AddTodoView: View {
    @ObservedObject var viewModel: AddTodoViewModel
    
    init(viewContext: NSManagedObjectContext, presenting: Binding<Bool>) {
        viewModel = AddTodoViewModel(context: viewContext, presenting: presenting)
    }
    
    var cancellables: Set<AnyCancellable> = [ ]
    
    var body: some View {
        NavigationView {
            GeometryReader { _ in
                VStack {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Task Description").font(.title3).foregroundColor(.secondary)
                        TextEditor(text: $viewModel.task).border(Color.secondary, width: 1)
                    }
                    DatePicker("Select when to finish this task.", selection: .init(get: {
                        viewModel.due
                    }, set: {
                        viewModel.due = $0
                    }))
                    .datePickerStyle(GraphicalDatePickerStyle())
                }
                .padding()
                .navigationTitle("Add Todo")
                .toolbar {
                    Button(action: viewModel.save) {
                        Text("Save")
                    }
                }
                .alert(
                    isPresented: Binding<Bool>.init(
                        get: {
                            viewModel.errorMessage != nil
                        },
                        set: { _ in
                            viewModel.errorMessage = nil
                        })
                ) {
                    Alert(title: Text("Please input all columns"), message: nil, dismissButton: nil)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }
    
    
}

struct AddTodoView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoView(viewContext: PersistenceController.preview.container.viewContext, presenting: Binding<Bool>.init(get: { true }, set: { _ in }))
    }
}
