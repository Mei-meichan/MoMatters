//
//  InstructionsView.swift
//  PurpawsGaiLyn
//
//  Created by STUDENT on 11/15/24.
//

import Foundation
import SwiftUI

// Create a new file: InstructionsView.swift
struct InstructionsView: View {
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Image
                    Image("foot-print") // Use your app's illustration
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.top, 20)
                    
                    // Title
                    Text("How to Count Kicks")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 240/255, green: 90/255, blue: 126/255))
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 20) {
                        InstructionStep(
                            number: "1",
                            title: "Pick Your Time",
                            description: "Count at the same time every day, when your baby is usually active."
                        )
                        
                        InstructionStep(
                            number: "2",
                            title: "Get Into Position",
                            description: "Sit with your feet up or lie on your side, just make sure you're comfortable."
                        )
                        
                        InstructionStep(
                            number: "3",
                            title: "Start Counting",
                            description: "Press the button every time you feel a kick, twist, turn, swish, or roll."
                        )
                        
                        InstructionStep(
                            number: "4",
                            title: "Track Your Time",
                            description: "Note how long it takes to get to 10 movements. You're done for the day!"
                        )
                        
                        InstructionStep(
                            number: "5",
                            title: "Daily Tracking",
                            description: "Repeat this process every day to establish your baby's pattern."
                        )
                    }
                    .padding(.horizontal)
                    
                    // Important Note
                    VStack(spacing: 12) {
                        Text("Important Note")
                            .font(.headline)
                            .foregroundColor(Color(red: 240/255, green: 90/255, blue: 126/255))
                        
                        Text("If you notice a significant change in your baby's movement pattern, contact your healthcare provider right away.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 255/255, green: 240/255, blue: 240/255))
                    )
                    .padding(.horizontal)
                    
                    // Got It Button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Got It!")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Color(red: 240/255, green: 90/255, blue: 126/255)
                            )
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

// Helper view for instruction steps
struct InstructionStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step Number
            ZStack {
                Circle()
                    .fill(Color(red: 240/255, green: 90/255, blue: 126/255))
                    .frame(width: 30, height: 30)
                
                Text(number)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
