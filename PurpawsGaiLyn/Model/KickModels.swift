//
//  KickModels.swift
//  PurpawsGaiLyn
//
//  Created by STUDENT on 11/15/24.
//

import Foundation


// Models/KickModels.swift
enum KickType: String, CaseIterable, Identifiable {
    case tap = "Tap"
    case twist = "Twist"
    case turn = "Turn"
    case swish = "Swish"
    case roll = "Roll"
    case jab = "Jab"
    case punch = "Punch"
    case kick = "Kick"
    case vibrate = "Vibrate"
    case unknown = "I don't know"
    
    var id: String { self.rawValue }
}

struct KickReminder: Identifiable, Codable {
    var id = UUID()
    var time: Date
    var isEnabled: Bool
}
