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
        todo.task = "finish homework"
        return todo
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todo: previewTodo(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), todo: previewTodo(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()

        guard let todos = try? viewContext.fetch(.init(entityName: "Todo")) as? [Todo] else {
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
            return
        }
        if todos.isEmpty {
            let todo = previewTodo()
            entries.append(SimpleEntry(date: currentDate, todo: todo, configuration: configuration))
        }
        entries = todos.map {
            SimpleEntry(date: currentDate, todo: $0, configuration: configuration)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todo: Todo
    let configuration: ConfigurationIntent
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
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetAppEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}

struct WidgetApp_Previews: PreviewProvider {
    static var previews: some View {
        WidgetAppEntryView(entry: SimpleEntry(date: Date(), todo: Todo(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
