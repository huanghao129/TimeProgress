//
//  EventCardView.swift
//  TimeProgress
//
//  Created by Assistant on 2026/5/28.
//

import SwiftUI

struct EventCardView: View {
    let event: TimeEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: event.iconName)
                    .font(.title2)
                    .foregroundColor(event.color)
                
                Text(event.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(event.displayMode == .days ? "天" : "小时")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(event.color.opacity(0.15))
                    .cornerRadius(4)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(event.color.opacity(0.15))
                        .frame(height: 24)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [event.color.opacity(0.7), event.color]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * event.progress), height: 24)
                    
                    // Percentage text
                    Text(String(format: "%.1f%%", event.progress * 100))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
            }
            .frame(height: 24)
            
            // Time info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("已过去")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(event.elapsedTimeString)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("总计")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(event.totalTimeString)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("剩余")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(event.remainingTimeString)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }
}
