//
//  EventListView.swift
//  TimeProgress
//
//  Created by Assistant on 2026/5/28.
//

import SwiftUI
import Combine

struct EventListView: View {
    private struct EventRefreshIdentity: Hashable {
        let eventID: UUID
        let refreshID: UUID
    }

    @ObservedObject var store: EventStore
    @State private var showingAddEvent = false
    @State private var editingEvent: TimeEvent?
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if store.events.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(store.events) { event in
                            EventCardView(event: event)
                                .id(EventRefreshIdentity(eventID: event.id, refreshID: refreshID))
                                .contextMenu {
                                    Button {
                                        editingEvent = event
                                    } label: {
                                        Label("编辑", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        store.deleteEvent(event)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                                .onTapGesture {
                                    editingEvent = event
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(store: store)
            }
            .sheet(item: $editingEvent) { event in
                AddEventView(store: store, editingEvent: event)
            }
            .onReceive(timer) { _ in
                refreshID = UUID()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 100)
            
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("还没有事件")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("点击右上角 + 添加你的第一个事件")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
