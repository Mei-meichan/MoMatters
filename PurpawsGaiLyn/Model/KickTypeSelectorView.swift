//
//  KickSelectorView.swift
//  PurpawsGaiLyn
//
//  Created by STUDENT on 11/15/24.
//

import Foundation


import SwiftUI

struct KickTypeSelectorView: View {
    @ObservedObject var viewModel: KickCounterViewModel
    @Environment(\.presentationMode) var presentationMode // Changed from dismiss
    
    // Grid layout
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Animation properties
    @State private var selectedType: KickType?
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("SELECT KICK TYPE")
                    .font(.headline)
                    .padding(.top)
                
                // Grid of kick types
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(KickType.allCases) { type in
                            KickTypeButton(
                                type: type,
                                isSelected: selectedType == type
                            ) {
                                withAnimation(.spring()) {
                                    selectedType = type
                                    showConfirmation = true
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // I don't know option
                Button("I don't know") {
                    selectedType = .unknown
                    showConfirmation = true
                }
                .foregroundColor(.blue)
                .padding(.bottom)
                
                // Explanation text
                Text("Select the type of movement you felt to help track your baby's patterns")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationBarBackButtonHidden(true) // Hide default back button
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        presentationMode.wrappedValue.dismiss() // Changed here
//                    }
//                }
//            }
        }
        .alert("Confirm Kick Type", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {
                selectedType = nil
            }
            Button("Confirm") {
                if let type = selectedType {
                    viewModel.recordKick(type: type)
                    presentationMode.wrappedValue.dismiss() // Changed here
                }
            }
        } message: {
            if let type = selectedType {
                Text("Did you feel a \(type.rawValue.lowercased()) movement?")
            }
        }
    }
}

// Helper component for kick type buttons
struct KickTypeButton: View {
    let type: KickType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(type.rawValue.lowercased()) // Use your custom images
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(isSelected ? .white : .blue)
                    )
                    .shadow(radius: isSelected ? 4 : 0)
                
                Text(type.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}
