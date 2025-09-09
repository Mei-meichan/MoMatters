//
//  KickCounterViewModel.swift
//  PurpawsGaiLyn
//
//  Created by STUDENT on 11/15/24.
//

import Foundation


// ViewModels/KickCounterViewModel.swift
class KickCounterViewModel: ObservableObject {
    @Published var timeRemaining: TimeInterval = 60 * 60 // 60 minutes
    @Published var kickCount: Int = 0
    @Published var isActive = false
    @Published var showKickTypeSelector = false
    @Published var showStopAlert = false
    @Published var showResetAlert = false
    @Published var selectedTab = 0 // 0: Counter, 1: Reports, 2: Reminders
    @Published var reminders: [KickReminder] = [
        KickReminder(time: Calendar.current.date(from: DateComponents(hour: 9, minute: 30)) ?? Date(), isEnabled: true),
        KickReminder(time: Calendar.current.date(from: DateComponents(hour: 13, minute: 0)) ?? Date(), isEnabled: true),
        KickReminder(time: Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date(), isEnabled: true)
    ]
    @Published var editingReminder: KickReminder?
    @Published var showTimePicker = false
    
    private var timer: Timer?
//    private let haptics = UINotificationFeedbackGenerator()
    
    // Start the counter
    func startCounter() {
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    // Stop the counter
    func stopCounter() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    // Reset the counter
    func resetCounter() {
        stopCounter()
        timeRemaining = 60 * 60
        kickCount = 0
    }
    
    // Record a kick
    func recordKick(type: KickType) {
        guard isActive else { return }
        kickCount += 1
//        haptics.notificationOccurred(.success)
        showKickTypeSelector = false
    }
    
    // Update timer
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            stopCounter()
        }
    }
    
    // Format time for display
    func formattedTime() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
