//
//  EventStore.swift
//  TimeProgress
//
//  Created by Assistant on 2026/5/28.
//

import Combine
import Foundation
import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

class EventStore: ObservableObject {
    @Published var events: [TimeEvent] = []
    
    private let saveKey = "TimeProgressEvents"
    private let suiteName = "group.com.huanghao.TimeProgress"
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
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
            sharedDefaults?.set(data, forKey: saveKey)
            UserDefaults.standard.set(data, forKey: saveKey)
#if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
#endif
        }
    }
    
    private func loadEvents() {
        // The app group is treated as the source of truth so the widget and app always read the same payload.
        if let sharedData = sharedDefaults?.data(forKey: saveKey),
           let decoded = Self.decodeEvents(from: sharedData) {
            events = decoded
            UserDefaults.standard.set(sharedData, forKey: saveKey)
            return
        }

        if let localData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = Self.decodeEvents(from: localData) {
            events = decoded
            sharedDefaults?.set(localData, forKey: saveKey)
        }
    }
    
    // Static method for widget to load events
    static func loadEventsForWidget() -> [TimeEvent] {
        let suiteName = "group.com.huanghao.TimeProgress"
        let saveKey = "TimeProgressEvents"
        if let sharedDefaults = UserDefaults(suiteName: suiteName),
           let data = sharedDefaults.data(forKey: saveKey),
           let decoded = decodeEvents(from: data) {
            return decoded
        }
        return []
    }

    private static func decodeEvents(from data: Data) -> [TimeEvent]? {
        if let events = try? JSONDecoder().decode([TimeEvent].self, from: data) {
            return events
        }
        if let singleEvent = try? JSONDecoder().decode(TimeEvent.self, from: data) {
            return [singleEvent]
        }
        return nil
    }
}
