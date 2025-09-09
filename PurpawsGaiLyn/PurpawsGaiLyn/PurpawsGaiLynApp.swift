//
//  PurpawsApp.swift
//  Purpaws
//
//  Created by STUDENT on 10/18/24.
//

import SwiftUI
import Firebase

@main
struct PurpawsGaiLynApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
