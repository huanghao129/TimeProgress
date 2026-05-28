//
//  TimeEvent+Widget.swift
//  TimeProgressWidget
//
//  Shared model for widget to decode events from UserDefaults.
//

import Foundation
import SwiftUI

struct WorkSchedule: Codable, Equatable {
    var workDays: [Int]
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    
    static var defaultSchedule: WorkSchedule {
        WorkSchedule(
            workDays: [2, 3, 4, 5, 6],
            startHour: 0,
            startMinute: 0,
            endHour: 23,
            endMinute: 59
        )
    }
    
    var dailyWorkHours: Double {
        let startMinutes = Double(startHour * 60 + startMinute)
        let endMinutes = Double(endHour * 60 + endMinute)
        return (endMinutes - startMinutes) / 60.0
    }
    
    var useCustomSchedule: Bool {
        return !(workDays.sorted() == [2, 3, 4, 5, 6] && startHour == 0 && startMinute == 0 && endHour == 23 && endMinute == 59)
    }
}

struct TimeEvent: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var startDate: Date
    var endDate: Date
    var workSchedule: WorkSchedule
    var displayMode: DisplayMode
    
    enum DisplayMode: String, Codable, CaseIterable {
        case days = "天"
        case hours = "小时"
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    var totalWorkingDays: Int {
        let calendar = Calendar.current
        var count = 0
        var current = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        while current < endDay {
            let weekday = calendar.component(.weekday, from: current)
            if workSchedule.workDays.contains(weekday) { count += 1 }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return count
    }
    
    var totalHours: Double {
        if workSchedule.useCustomSchedule {
            return calculateElapsedWorkHours(from: startDate, to: endDate)
        }
        return endDate.timeIntervalSince(startDate) / 3600.0
    }
    
    var elapsedHours: Double {
        let now = Date()
        if now <= startDate { return 0 }
        if now >= endDate { return totalHours }
        if workSchedule.useCustomSchedule {
            return calculateElapsedWorkHours(from: startDate, to: now)
        }
        return now.timeIntervalSince(startDate) / 3600.0
    }
    
    var remainingHours: Double { max(0, totalHours - elapsedHours) }
    
    var progress: Double {
        guard totalHours > 0 else { return 0 }
        return min(1.0, max(0.0, elapsedHours / totalHours))
    }
    
    var remainingTimeString: String {
        switch displayMode {
        case .days:
            if workSchedule.useCustomSchedule {
                return String(format: "%.1f天", remainingHours / workSchedule.dailyWorkHours)
            }
            return String(format: "%.1f天", remainingHours / 24.0)
        case .hours:
            return String(format: "%.1f小时", remainingHours)
        }
    }

    private func calculateElapsedWorkHours(from start: Date, to now: Date) -> Double {
        let calendar = Calendar.current
        var totalElapsed: Double = 0
        var current = calendar.startOfDay(for: start)
        let today = calendar.startOfDay(for: now)

        while current <= today {
            let weekday = calendar.component(.weekday, from: current)

            if workSchedule.workDays.contains(weekday) {
                if current == today {
                    let workStart = calendar.date(
                        bySettingHour: workSchedule.startHour,
                        minute: workSchedule.startMinute,
                        second: 0,
                        of: current
                    )!
                    let workEnd = calendar.date(
                        bySettingHour: workSchedule.endHour,
                        minute: workSchedule.endMinute,
                        second: 0,
                        of: current
                    )!

                    if now > workStart {
                        let effectiveStart =
                            (current == calendar.startOfDay(for: start))
                            ? max(start, workStart)
                            : workStart

                        let effectiveEnd = min(now, workEnd)

                        if effectiveEnd > effectiveStart {
                            totalElapsed += effectiveEnd.timeIntervalSince(effectiveStart) / 3600.0
                        }
                    }
                } else if current == calendar.startOfDay(for: start) {
                    let workStart = calendar.date(
                        bySettingHour: workSchedule.startHour,
                        minute: workSchedule.startMinute,
                        second: 0,
                        of: current
                    )!
                    let workEnd = calendar.date(
                        bySettingHour: workSchedule.endHour,
                        minute: workSchedule.endMinute,
                        second: 0,
                        of: current
                    )!

                    let effectiveStart = max(start, workStart)
                    if effectiveStart < workEnd {
                        totalElapsed += workEnd.timeIntervalSince(effectiveStart) / 3600.0
                    }
                } else {
                    totalElapsed += workSchedule.dailyWorkHours
                }
            }

            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        return max(0, totalElapsed)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 122, 255)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
