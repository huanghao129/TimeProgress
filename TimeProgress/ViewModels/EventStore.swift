//
//  EventStore.swift
//  TimeProgress
//
//  Created by Assistant on 2026/5/28.
//

import Combine
import Foundation
import SwiftUI

class EventStore: ObservableObject {
    @Published var events: [TimeEvent] = []
    
    private let saveKey = "TimeProgressEvents"
    private let suiteName = "group.com.huanghao.TimeProgress"
    
    init() {
        loadEvents()
    }
    
    func addEvent(_ event: TimeEvent) {
        events.append(event)
        saveEvents()
    }
    
    func updateEvent(_ event: TimeEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            saveEvents()
        }
    }
    
    func deleteEvent(_ event: TimeEvent) {
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    func deleteEvents(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        saveEvents()
    }
    
    private func saveEvents() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: saveKey)
            // Also save to shared container for widget
            if let sharedDefaults = UserDefaults(suiteName: suiteName) {
                sharedDefaults.set(data, forKey: saveKey)
            }
        }
    }
    
    private func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TimeEvent].self, from: data) {
            events = decoded
        }
    }
    
    // Static method for widget to load events
    static func loadEventsForWidget() -> [TimeEvent] {
        let suiteName = "group.com.huanghao.TimeProgress"
        let saveKey = "TimeProgressEvents"
        if let sharedDefaults = UserDefaults(suiteName: suiteName),
           let data = sharedDefaults.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TimeEvent].self, from: data) {
            return decoded
        }
        return []
    }
}
