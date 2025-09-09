import SwiftUI

struct NotificationsPage: View {
    // The notifications array passed from the HomePage
    @Binding var notifications: [String]
    
    // Default pregnancy-related notifications
    private let defaultNotifications = [
        ("New Article: Top 10 Pregnancy Tips Every Mom Should Know!", "Learn the best tips to stay healthy and safe during your pregnancy."),
        ("New Post: How to Stay Healthy During Pregnancy", "Discover exercises, nutrition, and self-care tips."),
        ("Suggested Article: The Importance of Prenatal Care", "Why prenatal care is essential for you and your baby."),
        ("Reminder: Don't Forget to Track Your Baby's Kicks!", "Tracking your baby’s kicks is an important part of your pregnancy journey."),
        ("Latest Update: Best Foods for Pregnant Women in Their First Trimester", "Find out which foods to eat for a healthy pregnancy.")
    ]
    
    var body: some View {
        VStack {
            Text("Notifications")
                .font(.largeTitle)
                .bold()
                .padding()

            // If no notifications are present, show a placeholder message
            if notifications.isEmpty {
                Text("You have no new notifications.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // Notifications list
                List {
                    ForEach(notifications, id: \.self) { notification in
                        // Each notification cell (like a Facebook notification)
                        NotificationCard(notification: notification)
                    }
                }
            }
        }
        .navigationBarTitle("Notifications", displayMode: .inline)
        .onAppear {
            // Set default notifications if none are provided
            if notifications.isEmpty {
                notifications = defaultNotifications.map { $0.0 }  // We are only using the title for now
            }
        }
    }
}

struct NotificationCard: View {
    var notification: String

    var body: some View {
        NavigationLink(destination: ArticlesPage()) {
            HStack {
                Image(systemName: "bell.fill")  // Bell icon for each notification
                    .foregroundColor(.blue)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1), in: Circle())
                    .padding(.trailing, 10)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(notification)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text("Tap to read more")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.vertical, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

