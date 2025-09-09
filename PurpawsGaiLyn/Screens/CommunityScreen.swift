
import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Models
struct PregnancyPost: Identifiable, Equatable {
    let id: String
    let userId: String
    let username: String
    var content: String
    var imageData: Data?
    let weekNumber: Int?
    let category: PregnancyCategory
    let timestamp: Date
    var likes: Int
    var comments: [Comment]
    
    // Track whether the current user has liked the post
        var likedByCurrentUser: Bool = false
    
    static func == (lhs: PregnancyPost, rhs: PregnancyPost) -> Bool {
        lhs.id == rhs.id
    }
}

struct Comment: Identifiable, Equatable {
    let id: String
    let userId: String
    let username: String
    let content: String
    let timestamp: Date
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}

enum PregnancyCategory: String, CaseIterable {
    case weekByWeek = "Week by Week"
    case symptoms = "Symptoms"
    case nutrition = "Nutrition"
    case exercise = "Exercise"
    case birthStory = "Birth Stories"
    case questions = "Questions"
    case tips = "Tips & Advice"
}

// MARK: - View Model
class PregnancyCommunityViewModel: ObservableObject {
    @Published var posts: [PregnancyPost] = []
    @Published var selectedCategory: PregnancyCategory = .weekByWeek
    @Published var showingNewPostSheet = false
    @Published var isLoading = false
    
    // Store the current user's data here (userId, username)
    @Published var currentUser: User? = nil
    
    init() {
        loadSampleData()
        fetchUserData()
    }
    
    private func loadSampleData() {
        posts = [
            PregnancyPost(
                id: UUID().uuidString,
                userId: "user1",
                username: "Sarah",
                content: "Linggo 16 Araw 3: Ang aking bone structure ay binubuo ng 300 soft bones sa ngayon.",
                imageData: nil,
                weekNumber: 16,
                category: .weekByWeek,
                timestamp: Date(),
                likes: 12,
                comments: [],
                likedByCurrentUser: false // Initially not liked by current user
            )
        ]
    }
    
    func createPost(content: String, imageData: Data?, category: PregnancyCategory, weekNumber: Int?) {
        guard let user = currentUser else { return }
        let newPost = PregnancyPost(
            id: UUID().uuidString,
            userId: user.id,
            username: user.username,
            content: content,
            imageData: imageData,
            weekNumber: weekNumber,
            category: category,
            timestamp: Date(),
            likes: 0,
            comments: []
        )
        posts.insert(newPost, at: 0)
    }
    
    func updatePost(_ post: PregnancyPost, newContent: String) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            var updatedPost = post
            updatedPost.content = newContent
            posts[index] = updatedPost
        }
    }
    
    func deletePost(_ post: PregnancyPost) {
        posts.removeAll { $0.id == post.id }
    }
    
    func addComment(to post: PregnancyPost, content: String) {
        guard let user = currentUser else { return }
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            var updatedPost = post
            let newComment = Comment(
                id: UUID().uuidString,
                userId: user.id,
                username: user.username,
                content: content,
                timestamp: Date()
            )
            updatedPost.comments.append(newComment)
            posts[index] = updatedPost
        }
    }
    
//    func likePost(_ post: PregnancyPost) {
//        if let index = posts.firstIndex(where: { $0.id == post.id }) {
//            var updatedPost = post
//            updatedPost.likes += 1
//            posts[index] = updatedPost
//        }
//    }
    
    func likePost(_ post: PregnancyPost) {
            guard let user = currentUser else { return }

            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                var updatedPost = post
                if updatedPost.likedByCurrentUser {
                    updatedPost.likes -= 1
                } else {
                    updatedPost.likes += 1
                }
                updatedPost.likedByCurrentUser.toggle() // Toggle the liked status
                posts[index] = updatedPost
            }
        }
    
    // Function to fetch user data from Firebase
    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }

        // Retrieve user data from Firestore (or other data sources)
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let username = document.get("username") as? String ?? "No Name"
                let userId = document.documentID
                self?.currentUser = User(id: userId, username: username)
            } else {
                print("User document does not exist")
            }
        }
    }
}

// Model for User
struct User {
    let id: String
    let username: String
}



// MARK: - Main View
struct CommunityScreen: View {
    @StateObject private var viewModel = PregnancyCommunityViewModel()
    @State private var searchText = ""
    @State private var selectedPost: PregnancyPost?
        @State private var showingNewPost = false
        
  
    
    var filteredPosts: [PregnancyPost] {
        if searchText.isEmpty {
            return viewModel.posts
        }
        return viewModel.posts.filter {
            $0.content.lowercased().contains(searchText.lowercased()) ||
            $0.username.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            SearchBar(text: $searchText)
                .padding()
            
            // Categories
            CategoryScrollView(selectedCategory: $viewModel.selectedCategory)
            
            // Create Post Button
                    CreatePostButton(action: { showingNewPost = true })
            
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
            
            // Bottom Navigation
            BottomNavigationBar()
        }
        // Present the new post view as a full screen modal
               .fullScreenCover(isPresented: $showingNewPost) {
                   NewPostView(viewModel: viewModel, showingNewPost: $showingNewPost, selectedPost: $selectedPost)
               }
               // Navigate to post detail when a new post is created
               .sheet(item: $selectedPost) { post in
                   NavigationView {
                       CommunityPostDetail(post: post, viewModel: viewModel)
                   }
               }
    }
}

// MARK: - Supporting Views
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search...", text: $text)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}
struct CategoryScrollView: View {
    @Binding var selectedCategory: PregnancyCategory

    var body: some View {
        // Horizontal Scroll View
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PregnancyCategory.allCases, id: \.self) { category in
                    Button(action: {
                        // Update selected category
                        selectedCategory = category
                    }) {
                        Text(category.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ?
                                        Color(red: 255/255, green: 78/255, blue: 104/255) : Color.gray.opacity(0.2))
                            .foregroundColor(selectedCategory == category ? .white : .black)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.red : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(20)
        }
    }
}

struct CreatePostButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "person.fill")
                        .foregroundColor(.gray))
                
                Text("What's on your mind?")
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

struct PregnancyPostCard: View {
    let post: PregnancyPost
    @ObservedObject var viewModel: PregnancyCommunityViewModel
    @State private var showingComments = false
    @State private var showingDeleteAlert = false
    @State private var isEditing = false
    @State private var editedContent = ""
    
    var body: some View {
        NavigationLink(destination: CommunityPostDetail(post: post, viewModel: viewModel)) {
            VStack(alignment: .leading, spacing: 12) {
                // Post Header
                PostHeader(post: post, isEditing: $isEditing, showingDeleteAlert: $showingDeleteAlert)
                
                // Content
                if isEditing {
                    EditPostView(content: $editedContent, onSave: {
                        viewModel.updatePost(post, newContent: editedContent)
                        isEditing = false
                    }, onCancel: {
                        isEditing = false
                    })
                    .onAppear { editedContent = post.content }
                } else {
                    Text(post.content)
                        .lineLimit(3)
                    
                    if let imageData = post.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(10)
                    }
                }
                
                // Interaction Buttons
                PostInteractionButtons(
                    likes: post.likes,
                    comments: post.comments.count,
                    onLike: { viewModel.likePost(post) },
                    onComment: { showingComments = true }
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Delete Post", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deletePost(post)
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingComments) {
            CommentsView(post: post, viewModel: viewModel)
        }
    }
}

struct PostHeader: View {
    let post: PregnancyPost
    @Binding var isEditing: Bool
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "person.fill")
                    .foregroundColor(.gray))
            
            VStack(alignment: .leading) {
                Text(post.username)
                    .font(.headline)
                if let week = post.weekNumber {
                    Text("Week \(week)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Menu {
                Button("Edit") { isEditing = true }
                Button("Delete", role: .destructive) {
                    showingDeleteAlert = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct PostInteractionButtons: View {
    let likes: Int
    let comments: Int
    let onLike: () -> Void
    let onComment: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onLike) {
                HStack {
                    Image(systemName: "heart")
                    Text("\(likes)")
                }
            }
            
            Spacer()
            
            Button(action: onComment) {
                HStack {
                    Image(systemName: "bubble.left")
                    Text("\(comments)")
                }
            }
        }
        .foregroundColor(.gray)
    }
}

struct BottomNavigationBar: View {
    var body: some View {
        HStack(spacing: 0) {
            ForEach(["Community", "Articles", "Tracker", "Mama's C", "Poll"], id: \.self) { item in
//                NavigationButton(item: item)
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .shadow(radius: 1)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}
// MARK: - New Post View with Direct Navigation to Detail
struct NewPostView: View {
    @ObservedObject var viewModel: PregnancyCommunityViewModel
    @Binding var showingNewPost: Bool
    @Binding var selectedPost: PregnancyPost?
    @State private var content = ""
    @State private var category: PregnancyCategory = .weekByWeek
    @State private var weekNumber = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Category Selection Section
                Section(header: Text("Post Details").foregroundColor(.gray)) {
                    Picker("Category", selection: $category) {
                        ForEach(PregnancyCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    // Week Number input for Week by Week category
                    if category == .weekByWeek {
                        TextField("Week Number", text: $weekNumber)
                            .keyboardType(.numberPad)
                    }
                    
                    // Content Input Area
                    VStack(alignment: .leading) {
                        Text("Content")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                // Photo Section
                Section(header: Text("Photo").foregroundColor(.gray)) {
                    Button(action: { showingImagePicker = true }) {
                        HStack {
                            Image(systemName: "photo")
                            Text(selectedImage == nil ? "Add Photo" : "Change Photo")
                        }
                    }
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationBarTitle("New Post", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingNewPost = false
                },
                trailing: Button("Post") {
                    if validatePost() {
                        createAndShowPost()
                    } else {
                        showingAlert = true
                    }
                }
                .disabled(content.isEmpty)
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Invalid Post"),
                message: Text("Please fill in all required fields."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Validate post input
    private func validatePost() -> Bool {
        if content.isEmpty { return false }
        if category == .weekByWeek && weekNumber.isEmpty { return false }
        return true
    }
    
    // Create post and navigate to detail view
    private func createAndShowPost() {
        guard let user = viewModel.currentUser else {
            print("Error: Current user is not available.")
            return
        }
        
        let weekNum = Int(weekNumber)
        let imageData = selectedImage?.jpegData(compressionQuality: 0.7)
        
        // Create the post
        let newPost = PregnancyPost(
            id: UUID().uuidString,
            userId: user.id,
            username: user.username,
            content: content,
            imageData: imageData,
            weekNumber: weekNum,
            category: category,
            timestamp: Date(),
            likes: 0,
            comments: []
        )
        
        // Add to view model
        viewModel.createPost(
            content: content,
            imageData: imageData,
            category: category,
            weekNumber: weekNum
        )
        
        // Close new post sheet and show detail view
        showingNewPost = false
//        selectedPost = newPost
    }
}

// MARK: - Edit Post View
struct EditPostView: View {
    @Binding var content: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Edit Text Area
            TextEditor(text: $content)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            // Action Buttons
            HStack {
                Button(action: onCancel) {
                    Text("Cancel")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: onSave) {
                    Text("Save")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Comments View
struct CommentsView: View {
    let post: PregnancyPost
    @ObservedObject var viewModel: PregnancyCommunityViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var newComment = ""
    @FocusState private var isCommentFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Comments List
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        // Original Post Preview
                        PostPreview(post: post)
                            .padding()
                        
                        Divider()
                        
                        // Comments
                        if post.comments.isEmpty {
                            NoCommentsView()
                        } else {
                            ForEach(post.comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                // Comment Input Area
                CommentInputArea(
                    newComment: $newComment,
                    isFocused: _isCommentFocused,
                    onSend: {
                        if !newComment.isEmpty {
                            viewModel.addComment(to: post, content: newComment)
                            newComment = ""
                            isCommentFocused = false
                        }
                    }
                )
            }
            .navigationBarTitle("Comments", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Supporting Views for Comments
struct PostPreview: View {
 
    let post: PregnancyPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Author Info
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading) {
                    Text(post.username)
                        .font(.headline)
                    Text(formatDate(post.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Post Content Preview
            Text(post.content)
                .lineLimit(3)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct NoCommentsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No comments yet")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Be the first to comment!")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // User Avatar
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                // Username and Timestamp
                HStack {
                    Text(comment.username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(formatDate(comment.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Comment Content
                Text(comment.content)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CommentInputArea: View {
    @Binding var newComment: String
    @FocusState var isFocused: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Comment TextField
            TextField("Write a comment...", text: $newComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isFocused)
            
            // Send Button
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(newComment.isEmpty ? .gray : .red)
            }
            .disabled(newComment.isEmpty)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}
