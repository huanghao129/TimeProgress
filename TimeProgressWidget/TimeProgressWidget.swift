//
//  TimeProgressWidget.swift
//  TimeProgressWidget
//
//  Created by Assistant on 2026/5/28.
//

import WidgetKit
import SwiftUI

struct EventEntry: TimelineEntry {
    let date: Date
    let event: TimeEvent?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> EventEntry {
        EventEntry(date: Date(), event: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (EventEntry) -> Void) {
        let events = loadEvents()
        let entry = EventEntry(date: Date(), event: events.first)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<EventEntry>) -> Void) {
        let events = loadEvents()
        let currentDate = Date()
        
        // Update every 15 minutes
        var entries: [EventEntry] = []
        for minuteOffset in stride(from: 0, to: 60, by: 15) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = EventEntry(date: entryDate, event: events.first)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadEvents() -> [TimeEvent] {
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

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

struct TimeProgressWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        if let event = entry.event {
            ZStack {
                CircularProgressView(progress: event.progress, color: event.color)
                    .padding(16)
                
                VStack(spacing: 4) {
                    Image(systemName: event.iconName)
                        .font(.title3)
                        .foregroundColor(event.color)
                    
                    Text(event.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(event.remainingTimeString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("添加事件")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        }
    }
}

struct TimeProgressWidget: Widget {
    let kind: String = "TimeProgressWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimeProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("时间进度")
        .description("显示事件时间进度")
        .supportedFamilies([.systemSmall])
    }
}
