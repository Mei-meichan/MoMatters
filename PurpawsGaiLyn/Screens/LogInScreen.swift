import SwiftUI
import FirebaseAuth

struct LoginScreen: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var navigateToHome: Bool = false
    @State private var showAlertError: Bool = false
    
    var body: some View {
        
        VStack {
            Spacer()
            
            // Logo image
            Image("loginn")
                .resizable()
                .frame(width: 200, height: 200)
            
            // Title Text
            Text("Log In.")
                .font(.system(size: 28, weight: .medium))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 185/255, green: 26/255, blue: 69/255))
         
            // Email TextField with styling improvements
            TextField("Email", text: $username)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            // Password SecureField with styling improvements
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                .padding(.horizontal)
            
            Spacer()
        
            // Login button
            Button(action: {
                // Call the login function when button is clicked
                login()
            }) {
                Text("LOGIN")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 255/255, green: 78/255, blue: 104/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Error message display
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Don't have an account? Sign up section (closer to login button)
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                    .font(.footnote)
                
                NavigationLink(destination: SignUpScreen()) {
                    Text("Sign Up")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                }
            }
            .padding(.top, 15)  // Reduced padding to bring elements closer
            
            Spacer()
            
            // Navigation link for navigating to HomePage
            NavigationLink(
                destination: HomePage(),
                isActive: $navigateToHome,
                label: { EmptyView() }
            )
        }
        .alert(isPresented: $showAlertError) {
            Alert(
                title: Text("User Not Found"),
                message: Text("Create an account first."),
                dismissButton: .default(Text("OK")) {
                    // Navigate to login form after dismissing alert
                }
            )
        }
        .navigationBarBackButtonHidden(true) // Hides the back button
    }
    
    func login() {
        Auth.auth().signIn(withEmail: username, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                print("User Not Found")
                showAlertError = true
            } else {
                print("User Found")
                navigateToHome = true
            }
        }
    }
}
