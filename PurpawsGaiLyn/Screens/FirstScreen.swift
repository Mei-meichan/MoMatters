import SwiftUI
import Firebase

 
struct FirstScreen: View {

     var body: some View {
         NavigationView {

             VStack {
                 Spacer()
                 
                 Image("logo_mm")
                     .resizable()
                     .frame(width: 250, height: 250)
                 
                 // MOMatters Text
                Text("Momatters")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 185/255, green: 26/255, blue: 69/255))
                    .padding(.top, 10)

                // Slogan
                Text("Because Every MOMent Matters.")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                 
                 Spacer()
              
                 NavigationLink(destination: LoginScreen()) {
                     Text("LOGIN")
                         .padding()
                         .frame(maxWidth: .infinity)
                         .background(Color(red: 255/255, green: 78/255, blue: 104/255))


                         .foregroundColor(.white)
                         .cornerRadius(10)
                 }
                 .padding(.horizontal)
                 
                 
                 // Sign Up Button
                 NavigationLink(destination: SignUpScreen()) {
                     Text("SIGN UP")
                         .padding()
                         .frame(maxWidth: .infinity)
                         .background(Color.clear)
                         .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                         .cornerRadius(10)
                         
                 }

                 .padding(.horizontal)
                 Spacer()
                 
                 
                 // Continue as Guest
                 Button(action: {
                     // Guest login action
                 }) {
                     Text("")
                         .foregroundColor(.gray)
                 }
                 .padding(.bottom, 20)
             }

         }

     }

 }


