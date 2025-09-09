import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpScreen: View {
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @State private var navigateToLogin: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("signupp") // Replace with an illustration or placeholder
                .resizable()
                .frame(width: 200, height: 200)
            
            // MOMatters Text
            Text("Sign Up.")
                .font(.system(size: 28, weight: .medium))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 185/255, green: 26/255, blue: 69/255))
            
            // Username field with styling
            TextField("Username", text: $username)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            // Email field with styling
            TextField("Email Address", text: $email)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            // Password field with styling
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                .padding(.horizontal)
            
            // Confirm Password field with styling
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                .padding(.horizontal)
            
            Spacer()
            
            // Sign Up button
            Button(action: {
                // Sign up action
                errorMessage = nil
                register()
            }) {
                Text("SIGN UP")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 255/255, green: 78/255, blue: 104/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Already have an account? Login button
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                    .font(.footnote)
                
                NavigationLink(destination: LoginScreen()) {
                    Text("Login")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                }
            }
            .padding(.top)
            
            Spacer()
            
            // Navigation link for navigating to Login
            NavigationLink(
                destination: LoginScreen(),
                isActive: $navigateToLogin,
                label: { EmptyView() }
            )
            
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(errorMessage?.contains("Sign Up Successful") == true ? "Success" : "Error"),
                message: Text(errorMessage ?? "Unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarBackButtonHidden(true) // Hides the back button
    }
    
    func register() {
        // Ensure all fields are filled
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields must be filled."
            showAlert = true
            return
        }
        
        // Check if passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        // Attempt to create a new Firebase user
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                // Successfully created user
                saveUsername() // Save username to Firestore
                errorMessage = "Sign Up Successful! You can now log in."
                showAlert = true
            }
        }
    }
    
    
    
    
    func saveUsername() {
        // Get the current user from FirebaseAuth
        guard let user = Auth.auth().currentUser else {
            print("No user logged in.")
            return
        }
        
        // Get Firestore instance
        let db = Firestore.firestore()
        
        // Create a document for the user with the user ID
        db.collection("users").document(user.uid).setData([
            "username": username,
            "email": email
        ]) { error in
            if let error = error {
                print("Error saving username: \(error.localizedDescription)")
            } else {
                print("Username saved successfully!")
            }
        }
    }
}

