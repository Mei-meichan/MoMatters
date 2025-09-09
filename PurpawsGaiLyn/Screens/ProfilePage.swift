import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfilePage: View {
    // User data states
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var showSignOutAlert = false
    @State private var navigateToLogin = false  // Control navigation to login screen
    @State private var emailNotificationsEnabled = false
    @State private var questionNotificationsEnabled = false
    @State private var questionsNotificationsEnabled = false
    @State private var weeklyNotificationsEnabled = false
    @State private var darkModeEnabled = false
    @State private var suggestionNotification = false
    @State private var hideModeEnabled = false
    @Environment(\.presentationMode) var presentationMode  // For dismissing the view after sign-out

    var body: some View {
        VStack(spacing: 20) {
            // Profile Header Section
            VStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                    .padding()

                Text(username)
                    .font(.title2)
                    .bold()
            }
            .padding(.top, 20)

            // Profile Information Section
            VStack(spacing: 15) {
                ProfileInfoRow(icon: "person.fill", title: "Username", value: username)
                ProfileInfoRow(icon: "envelope.fill", title: "Email", value: email)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            // Actions Section
            VStack(spacing: 15) {
                // Terms and Conditions Button
                NavigationLink(destination: TermsAndConditionsPage()) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                        Text("Terms and Conditions")
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .scaleEffect(1.05) // Slight scaling animation
                    .animation(.easeInOut(duration: 0.2), value: 1)
                }
                
                // Privacy and Policy Button
                NavigationLink(destination: PrivacyAndPolicyPage()) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                        Text("Privacy and Policy")
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .scaleEffect(1.05) // Slight scaling animation
                    .animation(.easeInOut(duration: 0.2), value: 1)
                }

                // Settings Button
                NavigationLink(destination: SettingsPage(
                    emailNotificationsEnabled: $emailNotificationsEnabled,
                    questionNotificationsEnabled: $darkModeEnabled,
                    questionsNotificationsEnabled: $questionNotificationsEnabled,
                    darkModeEnabled: $questionsNotificationsEnabled,
                    hideModeEnabled: $hideModeEnabled,
                    suggestionNotification: $suggestionNotification,
                    weeklyNotificationsEnabled: $weeklyNotificationsEnabled
                )) {
                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                        Text("Settings")
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .scaleEffect(1.05) // Slight scaling animation
                    .animation(.easeInOut(duration: 0.2), value: 1)
                }
            }
            .padding()

            Spacer()

            // Sign Out Button
            Button(action: {
    
                    showSignOutAlert = true
            
            }) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 255/255, green: 78/255, blue: 104/255))
                    .cornerRadius(10)
                  
            }
            .padding()
            .alert(isPresented: $showSignOutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .onAppear {
            fetchUserData()
        }
        // Navigation to Login Screen if the user has signed out
        .background(
            NavigationLink(destination: LoginScreen(), isActive: $navigateToLogin) {
                EmptyView()
            }
        )
    }

    // Function to fetch user data from Firebase
    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }

        // Retrieve user data from Firestore (or other data sources)
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                self.username = document.get("username") as? String ?? "No Name"
                self.email = document.get("email") as? String ?? "No Email"
            } else {
                print("User document does not exist")
            }
        }
    }

    // Sign out function
    private func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully")
            // Navigate to Login screen
            navigateToLogin = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError.localizedDescription)
        }
    }
}

// Profile Information Row Component
struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// Terms and Conditions Page
struct TermsAndConditionsPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("  Terms and Conditions")
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                Text("""
                    1. Introduction:
                    Welcome to MOMMatters! By accessing or using our service, you agree to comply with these terms and conditions.

                    2. Eligibility:
                    You must be 18 years or older to use our service. If you are under 18, you may use the service only with the consent of a parent or guardian.

                    3. User Responsibilities:
                    You are responsible for maintaining the confidentiality of your account and password.

                    4. Data Privacy:
                    We are committed to protecting your privacy. Your data will not be shared with third parties without your consent.

                    5. Limitation of Liability:
                    We are not responsible for any loss or damage caused by the use of our service. Our liability is limited to the maximum extent permitted by law.

                    6. Termination:
                    We reserve the right to suspend or terminate your account if you violate these terms.

                    7. Changes to Terms:
                    We may update our Terms and Conditions from time to time. Any changes will be posted on this page.

                    8. Contact Us:
                    If you have any questions about these Terms and Conditions, please contact us at support@mommatters.com.
                    """)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .navigationBarTitle("Terms and Conditions", displayMode: .inline)
    }
}

// Privacy and Policy Page
struct PrivacyAndPolicyPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("  Privacy and Policy")
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                Text("""
                    1. Introduction:
                    This Privacy Policy describes how MOMMatters collects, uses, and protects your personal data when you use our service.

                    2. Information We Collect:
                    We collect information such as your name, email, and other details you provide when signing up or interacting with the service.

                    3. Use of Information:
                    Your information is used to provide, maintain, and improve our service. We may also send you promotional content or updates.

                    4. Data Security:
                    We implement reasonable security measures to protect your information, but no method of transmission over the Internet is 100% secure.

                    5. Sharing Your Data:
                    We do not sell, rent, or share your personal data with third parties unless required by law or with your consent.

                    6. Your Rights:
                    You have the right to access, update, or delete your personal data. Please contact us for assistance.

                    7. Changes to Privacy Policy:
                    We may update our Privacy Policy from time to time. Any changes will be posted on this page.

                    8. Contact Us:
                    If you have any questions about this Privacy Policy, please contact us at privacy@mommatters.com.
                    """)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .navigationBarTitle("Privacy and Policy", displayMode: .inline)
    }
}

// Settings Page
struct SettingsPage: View {
    @Binding var emailNotificationsEnabled: Bool
    @Binding var questionNotificationsEnabled: Bool
    @Binding var questionsNotificationsEnabled: Bool
    @Binding var darkModeEnabled: Bool
    @Binding var hideModeEnabled: Bool
    @Binding var suggestionNotification: Bool
    @Binding var weeklyNotificationsEnabled: Bool

    var body: some View {
        Form {
            Section(header: Text("Email Notifications")) {
                Toggle(isOn: $emailNotificationsEnabled) {
                    Text("Daily Digest email")
                }
                .toggleStyle(CustomToggleStyle())
                .animation(.easeInOut(duration: 0.2), value: emailNotificationsEnabled)

                Toggle(isOn: $questionNotificationsEnabled) {
                    Text("Your Questions got answered")
                }
                .toggleStyle(CustomToggleStyle())
                .animation(.easeInOut(duration: 0.2), value: questionNotificationsEnabled)
                
                Toggle(isOn: $weeklyNotificationsEnabled) {
                    Text("Weekly Pregnancy Newsletter")
                }
                .toggleStyle(CustomToggleStyle())
                .animation(.easeInOut(duration: 0.2), value: weeklyNotificationsEnabled)
            }

            Section(header: Text("Push Preferences")) {
                Toggle(isOn: $questionsNotificationsEnabled) {
                    Text("Your Question got answered")
                }
                .toggleStyle(CustomToggleStyle())
                .animation(.easeInOut(duration: 0.2), value: questionsNotificationsEnabled)

                Toggle(isOn: $suggestionNotification) {
                    Text("Suggested Article")
                }
                .toggleStyle(CustomToggleStyle())
                .animation(.easeInOut(duration: 0.2), value: suggestionNotification)
            }
            
            Section(header: Text("Content Preferences")) {
                Toggle(isOn: $hideModeEnabled) {
                    Text("Hide NSFW post")
                }
                .toggleStyle(CustomToggleStyle())
                .animation(.easeInOut(duration: 0.2), value: hideModeEnabled)
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

// Custom Toggle Style to match the Sign Out button color
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 20)
                .fill(configuration.isOn ? Color(red: 255/255, green: 78/255, blue: 104/255) : Color.gray)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .padding(3)
                        .offset(x: configuration.isOn ? 12 : -12)
                )
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
