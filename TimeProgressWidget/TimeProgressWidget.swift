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
                .stroke(color.opacity(0.16), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color.opacity(0.7), color]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
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
                    .padding(12)
                
                VStack(spacing: 6) {
                    Text(event.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    Text(event.remainingTimeString)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(event.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 18)
            }
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        } else {
            VStack(spacing: 8) {
                Text("暂无事件")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("请先在 App 中创建时间")
                    .font(.caption2)
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
