//
//  TimeProgressWidget.swift
//  TimeProgressWidget
//
//  Created by 黄浩 on 2026/5/28.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry

struct TimeProgressEntry: TimelineEntry {
    let date: Date
    let event: TimeEvent?
}

// MARK: - Provider

struct TimeProgressProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TimeProgressEntry {
        TimeProgressEntry(date: Date(), event: .placeholder)
    }

    func snapshot(for configuration: SelectEventIntent, in context: Context) async -> TimeProgressEntry {
        let events = WidgetEventStore.loadEvents()
        return TimeProgressEntry(date: Date(), event: resolvedEvent(for: configuration, from: events))
    }

    func timeline(for configuration: SelectEventIntent, in context: Context) async -> Timeline<TimeProgressEntry> {
        let events = WidgetEventStore.loadEvents()
        let event = resolvedEvent(for: configuration, from: events)
        let now = Date()

        let entries: [TimeProgressEntry] = (0..<24).map { hour in
            let entryDate = Calendar.current.date(byAdding: .hour, value: hour, to: now)!
            return TimeProgressEntry(date: entryDate, event: event)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    // MARK: - Helpers

    private func resolvedEvent(for configuration: SelectEventIntent, from events: [TimeEvent]) -> TimeEvent? {
        if let selectedId = configuration.event?.id,
           let uuid = UUID(uuidString: selectedId),
           let selectedEvent = events.first(where: { $0.id == uuid }) {
            return selectedEvent
        }
        return mostRelevantEvent(from: events)
    }

    /// Returns the most relevant event: active > upcoming > most-recently-completed.
    private func mostRelevantEvent(from events: [TimeEvent]) -> TimeEvent? {
        let now = Date()
        if let active = events
            .filter({ $0.startDate <= now && $0.endDate > now })
            .min(by: { $0.endDate < $1.endDate }) {
            return active
        }
        if let upcoming = events
            .filter({ $0.startDate > now })
            .min(by: { $0.startDate < $1.startDate }) {
            return upcoming
        }
        return events.max(by: { $0.endDate < $1.endDate })
    }
}

enum WidgetEventStore {
    private static let suiteName = "group.com.huanghao.TimeProgress"
    private static let saveKey = "TimeProgressEvents"

    static func loadEvents() -> [TimeEvent] {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: saveKey),
              let events = try? JSONDecoder().decode([TimeEvent].self, from: data) else {
            return []
        }
        return events
    }
}

// MARK: - Placeholder Event

private extension TimeEvent {
    static let placeholder = TimeEvent(
        id: UUID(),
        name: "示例事件",
        iconName: "star.fill",
        colorHex: "#007AFF",
        startDate: Date().addingTimeInterval(-86400),
        endDate: Date().addingTimeInterval(86400 * 6),
        workSchedule: .defaultSchedule,
        displayMode: .days
    )
}

// MARK: - Widget View

struct TimeProgressWidgetEntryView: View {
    var entry: TimeProgressEntry

    var body: some View {
        if let event = entry.event {
            ZStack {
                // Background track
                Circle()
                    .stroke(event.color.opacity(0.2), lineWidth: 10)
                    .padding(6)

                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(event.progress))
                    .stroke(
                        event.color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .padding(6)

                // Center labels
                VStack(spacing: 4) {
                    Text(event.name)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)

                    Text(event.remainingTimeString)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(event.color)
                }
                .padding(28)
            }
        } else {
            VStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text("暂无事件")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Widget Configuration

struct TimeProgressWidget: Widget {
    let kind: String = "TimeProgressWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectEventIntent.self, provider: TimeProgressProvider()) { entry in
            TimeProgressWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("时间进度")
        .description("显示事件的剩余时间和进度。")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    TimeProgressWidget()
} timeline: {
    TimeProgressEntry(date: .now, event: .placeholder)
    TimeProgressEntry(date: .now, event: nil)
}
