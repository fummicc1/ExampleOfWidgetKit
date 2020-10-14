//
//  ExampleOfWidgetKitApp.swift
//  ExampleOfWidgetKit
//
//  Created by Fumiya Tanaka on 2020/10/12.
//

import SwiftUI

@main
struct ExampleOfWidgetKitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// dismiss Keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
