//
//  EventStore.swift
//  TimeProgress
//
//  Created by Assistant on 2026/5/28.
//

import Combine
import Foundation
import SwiftUI
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

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
            syncSharedEvents(data)
#if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
#endif
        }
    }
    
    private func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TimeEvent].self, from: data) {
            events = decoded
            syncSharedEventsIfNeeded(data)
        } else if let sharedDefaults = UserDefaults(suiteName: suiteName),
                  let data = sharedDefaults.data(forKey: saveKey),
                  let decoded = try? JSONDecoder().decode([TimeEvent].self, from: data) {
            events = decoded
            UserDefaults.standard.set(data, forKey: saveKey)
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

    private func syncSharedEvents(_ data: Data) {
        guard let sharedDefaults = UserDefaults(suiteName: suiteName) else { return }
        sharedDefaults.set(data, forKey: saveKey)
    }

    private func syncSharedEventsIfNeeded(_ data: Data) {
        guard let sharedDefaults = UserDefaults(suiteName: suiteName) else { return }
        guard sharedDefaults.data(forKey: saveKey) != data else { return }
        sharedDefaults.set(data, forKey: saveKey)
    }
}
