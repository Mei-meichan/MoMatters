import SwiftUI
import UserNotifications
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

// COMMUNITY PAGE (FIRST PAGE)
struct HomePage: View {
    let homeItems = homeItemsData
    @State private var searchText = "" // For search functionality
    @State private var navigateToProfile = false // For profile navigation
    @State private var selectedTab: Tab = .home // Track the selected tab
    @StateObject private var viewModel = PregnancyCommunityViewModel()
    @State private var selectedPost: PregnancyPost?
    @State private var showingNewPost = false
    @State private var unreadNotifications = 5 // Example unread notifications count
    
    // Store notifications in an array
    @State private var notifications: [String] = []
    
    enum Tab {
        case home
        case community
        case article
        case heart
        case profile
    }

    var filteredPosts: [PregnancyPost] {
        if searchText.isEmpty {
            return viewModel.posts
        }
        return viewModel.posts.filter {
            $0.content.lowercased().contains(searchText.lowercased()) ||
            $0.username.lowercased().contains(searchText.lowercased())
        }
    }

    var filteredItems: [HomeItem] {
        if searchText.isEmpty {
            return homeItems
        } else {
            return homeItems.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar with Search and Notifications
            HStack(spacing: 10) {
                // Search Bar
                SearchBar(text: $searchText)
                
                // Notifications Button
                NavigationLink(destination: NotificationsPage(notifications: $notifications)) {
                    ZStack {
                        Image(systemName: "bell.fill")
                            .font(.title)
                            .foregroundColor(Color(red: 255/255, green: 78/255, blue: 104/255))

                        // Display unread notification count if there are any unread notifications
                        if unreadNotifications > 0 {
                            Text("\(unreadNotifications)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Circle().fill(Color.red))
                                .offset(x: 12, y: -10)
                        }
                    }
                }
            }
            .padding()
            .shadow(radius: 1)
            
            ScrollView {
                // Categories
                CategoryScrollView(selectedCategory: $viewModel.selectedCategory)
                
                // Create Post Button
                CreatePostButton(action: { showingNewPost = true })
                
                FeauturedCali()
                    .frame(height: 200)
                    .padding(.vertical)
                
                // Posts List
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPosts) { post in
                                PregnancyPostCard(post: post, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }

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
        }
        .fullScreenCover(isPresented: $showingNewPost) {
            NewPostView(viewModel: viewModel, showingNewPost: $showingNewPost, selectedPost: $selectedPost)
        }
        .sheet(item: $selectedPost) { post in
            NavigationView {
                CommunityPostDetail(post: post, viewModel: viewModel)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Example: Start with some unread notifications
            unreadNotifications = 5
        }
    }
    
    // Function to trigger local notifications
    func triggerLocalNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Notification"
        content.body = message
        content.sound = .default
        
        // Set the badge number (this simulates unread notification count)
        content.badge = NSNumber(value: unreadNotifications + 1)
        
        // Add the message to the notifications list
        notifications.append(message)
        
        // Create the notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
        
        // Update the unread notification count
        unreadNotifications += 1
    }
}

// Featured California View
struct FeauturedCali: View {
    let featuredCali = ["hellobaby", "sheesh1", "sheesh2"]
    
    var body: some View {
        TabView {
            ForEach(featuredCali, id: \.self) { cali in
                Image(cali)
                    .resizable()
                    .clipped()
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .frame(height: 200)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .navigationBarBackButtonHidden(true)
    }
}
