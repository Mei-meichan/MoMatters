//
//  KickCounterView.swift
//  PurpawsGaiLyn
//
//  Created by STUDENT on 11/15/24.
//

import Foundation
import SwiftUI


// Views/KickCounterView.swift
struct KickCounterView: View {
    @StateObject private var viewModel = KickCounterViewModel()
    @State private var rotationAngle: Double = 0
    @State private var showAnimation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Bar
                CustomTabBar(selectedTab: $viewModel.selectedTab)
                
                TabView(selection: $viewModel.selectedTab) {
                    // Counter View
                    CounterMainView(viewModel: viewModel)
                        .tag(0)
                    
                    // Reports View (Placeholder)
                    ReportsView()
                        .tag(1)
                    
                    // Reminders View
                    RemindersView(viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Kick Counter")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
