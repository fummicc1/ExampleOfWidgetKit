//
//  TodoDateFormatter.swift
//  ExampleOfWidgetKit
//
//  Created by Fumiya Tanaka on 2020/10/12.
//

import Foundation

let todoDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
