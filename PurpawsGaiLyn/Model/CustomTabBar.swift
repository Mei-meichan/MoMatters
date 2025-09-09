//
//  CustomTabBar.swift
//  PurpawsGaiLyn
//
//  Created by STUDENT on 11/15/24.
//

import Foundation
// MARK: - CustomTabBar.swift
//
// A custom tab bar component for switching between Counter, Reports, and Reminders
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    // Tab item data
    private let tabs = [
        TabItem(icon: "foot.fill", title: "Counter"),
        TabItem(icon: "chart.bar.fill", title: "Reports"),
        TabItem(icon: "bell.fill", title: "Reminders")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 20))
                        
                        Text(tabs[index].title)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == index ? .blue : .gray)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedTab == index ?
                        Color.white :
                        Color.clear
                    )
                    .cornerRadius(12)
                }
            }
        }
        .padding(8)
        .background(Color.blue.opacity(0.1))
    }
}

// Helper struct for tab items
private struct TabItem {
    let icon: String
    let title: String
}
