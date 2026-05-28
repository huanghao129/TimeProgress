//
//  ContentView.swift
//  TimeProgress
//
//  Created by 黄浩 on 2026/5/28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = EventStore()
    
    var body: some View {
        EventListView(store: store)
    }
}

#Preview {
    ContentView()
}
