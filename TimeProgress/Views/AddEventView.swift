//
//  AddEventView.swift
//  TimeProgress
//
//  Created by Assistant on 2026/5/28.
//

import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: EventStore
    
    var editingEvent: TimeEvent?
    
    @State private var name: String = ""
    @State private var iconName: String = "star.fill"
    @State private var selectedColorHex: String = "#007AFF"
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(86400 * 7)
    @State private var displayMode: TimeEvent.DisplayMode = .hours
    @State private var useCustomSchedule: Bool = false
    @State private var workDays: Set<Int> = [2, 3, 4, 5, 6]
    @State private var workStartTime: Date = Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date())!
    @State private var workEndTime: Date = Calendar.current.date(bySettingHour: 17, minute: 30, second: 0, of: Date())!
    
    private let availableIcons = [
        "star.fill", "heart.fill", "book.fill", "briefcase.fill",
        "graduationcap.fill", "airplane", "car.fill", "house.fill",
        "trophy.fill", "flag.fill", "bolt.fill", "flame.fill",
        "leaf.fill", "music.note", "gamecontroller.fill", "paintbrush.fill",
        "wrench.fill", "gift.fill", "clock.fill", "calendar"
    ]
    
    private let availableColors: [(String, String)] = [
        ("#007AFF", "蓝色"),
        ("#FF3B30", "红色"),
        ("#34C759", "绿色"),
        ("#FF9500", "橙色"),
        ("#AF52DE", "紫色"),
        ("#FF2D55", "粉色"),
        ("#5AC8FA", "浅蓝"),
        ("#FFCC00", "黄色"),
        ("#8E8E93", "灰色"),
        ("#00C7BE", "青色")
    ]
    
    private let weekdays: [(Int, String)] = [
        (2, "周一"), (3, "周二"), (4, "周三"), (5, "周四"),
        (6, "周五"), (7, "周六"), (1, "周日")
    ]
    
    var isEditing: Bool { editingEvent != nil }
    
    var body: some View {
        NavigationView {
            Form {
                // Event name
                Section(header: Text("事件名称")) {
                    TextField("输入事件名称", text: $name)
                }
                
                // Icon selection
                Section(header: Text("图标")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(iconName == icon ? Color(hex: selectedColorHex).opacity(0.2) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(iconName == icon ? Color(hex: selectedColorHex) : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    iconName = icon
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Color selection
                Section(header: Text("颜色")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(availableColors, id: \.0) { colorHex, _ in
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColorHex == colorHex ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColorHex = colorHex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Time settings
                Section(header: Text("时间设置")) {
                    DatePicker("开始时间", selection: $startDate)
                    DatePicker("结束时间", selection: $endDate)
                }
                
                // Display mode
                Section(header: Text("显示模式")) {
                    Picker("时间单位", selection: $displayMode) {
                        ForEach(TimeEvent.DisplayMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Work schedule
                Section(header: Text("工作时间设置")) {
                    Toggle("自定义工作时间", isOn: $useCustomSchedule)
                    
                    if useCustomSchedule {
                        // Work days
                        VStack(alignment: .leading, spacing: 8) {
                            Text("工作日")
                                .font(.subheadline)
                            
                            HStack(spacing: 4) {
                                ForEach(weekdays, id: \.0) { day, label in
                                    Text(label)
                                        .font(.caption)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(workDays.contains(day) ? Color(hex: selectedColorHex).opacity(0.3) : Color.gray.opacity(0.1))
                                        )
                                        .onTapGesture {
                                            if workDays.contains(day) {
                                                workDays.remove(day)
                                            } else {
                                                workDays.insert(day)
                                            }
                                        }
                                }
                            }
                        }
                        
                        DatePicker("每天开始时间", selection: $workStartTime, displayedComponents: .hourAndMinute)
                        DatePicker("每天结束时间", selection: $workEndTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑事件" : "新建事件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEvent()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let event = editingEvent {
                    name = event.name
                    iconName = event.iconName
                    selectedColorHex = event.colorHex
                    startDate = event.startDate
                    endDate = event.endDate
                    displayMode = event.displayMode
                    useCustomSchedule = event.workSchedule.useCustomSchedule
                    workDays = Set(event.workSchedule.workDays)
                    let calendar = Calendar.current
                    workStartTime = calendar.date(bySettingHour: event.workSchedule.startHour, minute: event.workSchedule.startMinute, second: 0, of: Date())!
                    workEndTime = calendar.date(bySettingHour: event.workSchedule.endHour, minute: event.workSchedule.endMinute, second: 0, of: Date())!
                }
            }
        }
    }
    
    private func saveEvent() {
        let calendar = Calendar.current
        let schedule: WorkSchedule
        
        if useCustomSchedule {
            schedule = WorkSchedule(
                workDays: Array(workDays).sorted(),
                startHour: calendar.component(.hour, from: workStartTime),
                startMinute: calendar.component(.minute, from: workStartTime),
                endHour: calendar.component(.hour, from: workEndTime),
                endMinute: calendar.component(.minute, from: workEndTime)
            )
        } else {
            schedule = .defaultSchedule
        }
        
        if var event = editingEvent {
            event.name = name
            event.iconName = iconName
            event.colorHex = selectedColorHex
            event.startDate = startDate
            event.endDate = endDate
            event.workSchedule = schedule
            event.displayMode = displayMode
            store.updateEvent(event)
        } else {
            let event = TimeEvent(
                name: name,
                iconName: iconName,
                colorHex: selectedColorHex,
                startDate: startDate,
                endDate: endDate,
                workSchedule: schedule,
                displayMode: displayMode
            )
            store.addEvent(event)
        }
        
        dismiss()
    }
}
