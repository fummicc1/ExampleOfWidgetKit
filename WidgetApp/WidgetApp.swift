//
//  WidgetApp.swift
//  WidgetApp
//
//  Created by Fumiya Tanaka on 2020/10/12.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    let viewContext = PersistenceController.preview.container.viewContext
    
    func previewTodo() -> Todo {
        let todo = Todo(context: viewContext)
        todo.due = Date().addingTimeInterval(60 * 60 * 6)
        todo.task = "No Todo"
        return todo
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        let configuration = TodoIntent()
        configuration.kind = .descending
        return SimpleEntry(date: Date(), todo: previewTodo(), intent: configuration)
    }
    
    func getSnapshot(for configuration: TodoIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), todo: previewTodo(), intent: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: TodoIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let intentKind = configuration.kind
        
        let todoOptional: Todo?
        
        switch intentKind {
        case .ascending:
            todoOptional = getTodo(ascending: true)
            
        case .descending:
            todoOptional = getTodo(ascending: false)
            
        default:
            todoOptional = nil
        }
        
        guard let todo = todoOptional else {
            let todo = previewTodo()
            entries.append(SimpleEntry(date: currentDate, todo: todo, intent: configuration))
            return
        }
        let entry = SimpleEntry(date: todo.due!, todo: todo, intent: configuration)
        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getTodo(ascending: Bool) -> Todo? {
        guard var todos = try? viewContext.fetch(.init(entityName: "Todo")) as? [Todo] else {
            return nil
        }
        todos.sort(by: {
            if let first = $0.due,
               let second = $1.due,
               first > Date() {
                return first < second
            }
            return false
        })
        if ascending {
            return todos.first
        }
        return todos.last
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todo: Todo
    let intent: TodoIntent
}

struct WidgetAppEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let due = entry.todo.due, let task = entry.todo.task {
                Text(task).font(.title3)
                Text("Todo at \(due, formatter: todoDateFormatter)")
            }
        }.padding(4)
    }
}

@main
struct WidgetApp: Widget {
    let kind: String = "WidgetApp"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: TodoIntent.self, provider: Provider()) { entry in
            WidgetAppEntryView(entry: entry)
        }
        .configurationDisplayName("Todo Glance")
        .description("You can switch Todo Order, ascending or deascending.")
        .supportedFamilies([.systemMedium])
    }
}

struct WidgetApp_Previews: PreviewProvider {
    static var previews: some View {
        WidgetAppEntryView(entry: SimpleEntry(date: Date(), todo: Todo(), intent: TodoIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
