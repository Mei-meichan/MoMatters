import SwiftUI

struct CounterMainView: View {
    @ObservedObject var viewModel: KickCounterViewModel
    @State private var showInstructions = false // Add this line
    @State private var selectedTab: Tab = .heart // Track the selected tab
    @State private var showReport = false // Add this line
    
    enum Tab {
        case home
        case community
        case article
        case heart
        case profile
    }
    
    var body: some View {
        VStack(spacing: 30) {
            
            HStack {
                           NavigationLink(destination: ReportsView()) {
                               Text("Reports")
                                   .font(.title3)
                                   .fontWeight(.bold)
                                   .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                           }
                           
                           Spacer()
                           
                NavigationLink(destination: RemindersView(viewModel: viewModel)) {
                               Text("Reminder")
                                   .font(.title3)
                                   .fontWeight(.bold)
                                   .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                           }
                       }
                       .padding(.horizontal)
            // Main Counter Circle
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color(red: 255/255, green: 208/255, blue: 208/255), lineWidth: 8)
                
                    .frame(width: 280, height: 280)
                
                // Tick marks
                ForEach(0..<12) { index in
                    Rectangle()
                        .fill(Color(red: 240/255, green: 90/255, blue: 126/255))

                        .frame(width: 2, height: 10)
                        .offset(y: -140)
                        .rotationEffect(.degrees(Double(index) * 30))
                }
                
                // Progress indicator
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .offset(y: -140)
                    .rotationEffect(.degrees(360 * (1 - viewModel.timeRemaining/(60*60))))
                
                // Center Button
                Button(action: {
                    if viewModel.isActive {
                        viewModel.showKickTypeSelector = true
                    } else {
                        withAnimation {
                            viewModel.startCounter()
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 240/255, green: 90/255, blue: 126/255))


                            .frame(width: 200, height: 200)
                        
                        if viewModel.isActive {
                            Image("foot-print")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                        } else {
                            Text("Start")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            // Control Buttons
            HStack(spacing: 100) {
                // Stop Button
                ControlButton(
                    action: { viewModel.showStopAlert = true },
                    icon: "stop.fill"
                )
                
                // Reset Button
                ControlButton(
                    action: { viewModel.showResetAlert = true },
                    icon: "arrow.clockwise"
                )
            }
            
            // Counter Displays
            HStack(spacing: 20) {
                CounterBox(title: "TIME REMAINING", value: viewModel.formattedTime())
                CounterBox(title: "COUNTED", value: "\(viewModel.kickCount)")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Information Links
            HStack {
                Button("HOW DOES KICK COUNTER\nWORK?") {
                    showInstructions = true

                }
                
//                NavigationLink(destination: InstructionsView(isPresented: <#T##Binding<Bool>#>)) { // Changed to NavigationLink
//                                    Text("HOW DOES KICK COUNTER\nWORK?")
//                                        .multilineTextAlignment(.center)
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                }
                .multilineTextAlignment(.center)
                Spacer()
                             
                Spacer()
                Button("KNOW MORE ABOUT KICK\nCOUNTER") {
                 
                }
                    .multilineTextAlignment(.center)
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding()
        }
        .sheet(isPresented: $showInstructions) {  // Add this sheet modifier
                   InstructionsView(isPresented: $showInstructions)
               }
        .padding(.top,50)
        
        // Bottom Navigation Bar
        HStack {
            NavigationLink(destination: HomePage()) {
                Image(systemName: selectedTab == .home ? "person.3.fill" : "person.3")
                    .font(.title)
                    .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
            }
            
            Spacer()
            
            NavigationLink(destination: ArticlesPage()) {
                Image(systemName: selectedTab == .article ? "newspaper.fill" : "newspaper")
                    .font(.title)
                    .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
            }
            
            Spacer()
            

            NavigationLink(destination: Shop()) {
                Image("logo_mm")

                    .resizable()
                    .frame(width: 50, height: 50)
                
                    .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
            }
            
            Spacer()
        
            NavigationLink(destination: CounterMainView(viewModel: KickCounterViewModel())) {
                Image(systemName: selectedTab == .heart ? "arrow.clockwise.heart.fill" : "arrow.clockwise.heart")
                    .font(.title)
                    .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
            }
            
            Spacer()
            
            NavigationLink(destination: ProfilePage()) {
                Image(systemName: selectedTab == .profile ? "person.fill" : "person")
                    .font(.title)
                    .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
            }
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 1)
    
        .navigationBarHidden(true)
 
        
        
        
        
    
        NavigationLink(
            destination: KickTypeSelectorView(viewModel: viewModel),
            isActive: $viewModel.showKickTypeSelector
        ) {
            EmptyView()
        }
        .alert("Stop Counter?", isPresented: $viewModel.showStopAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Stop", role: .destructive) {
                viewModel.stopCounter()
            }
        }
        .alert("Reset Counter?", isPresented: $viewModel.showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetCounter()
            }
        }
    }
}

// MARK: - Helper Components for CounterMainView

// Control button used for stop and reset
struct ControlButton: View {
    let action: () -> Void
    let icon: String
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.white)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))
                        .font(.title2)
                )
                .shadow(radius: 2)
        }
    }
}

// Counter display box
struct CounterBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
