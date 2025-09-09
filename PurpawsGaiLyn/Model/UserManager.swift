//
//  UserManager.swift
//  Purpaws
//
//  Created by STUDENT on 10/18/24.
//

import Foundation

 
class UserManager {
    static let shared = UserManager()
 
    // In-memory storage for users
    private var users: [String: String] = [:] // Dictionary to store username and password
 
    // Sign up a new user
    func signUp(username: String, password: String) -> String? {
        // Check if the username already exists
        if users[username] != nil {
            return "Username is already taken."
        }
        
        // Store the new user
        users[username] = password
        return nil // No error, sign-up successful
    }
 
    // Log in an existing user
    func login(username: String, password: String) -> String? {
        // Check if the user exists
        guard let storedPassword = users[username] else {
            return "User not found."
        }
        
        // Check if the password matches
        if storedPassword == password {
            return nil // Login successful
        } else {
            return "Incorrect password."
        }
    }
}
