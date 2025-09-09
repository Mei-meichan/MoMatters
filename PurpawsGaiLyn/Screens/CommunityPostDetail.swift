
import SwiftUI
import PhotosUI

// MARK: - Main Post Detail View
struct CommunityPostDetail: View {
    // MARK: - Properties
    let post: PregnancyPost
    @ObservedObject var viewModel: PregnancyCommunityViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // State variables for user interactions
    @State private var newComment = ""
    @FocusState private var isCommentFocused: Bool
    @State private var showingOptions = false
    @State private var showingDeleteAlert = false
    @State private var isEditing = false
    @State private var editedContent: String
    
    // Initialize edited content with post content
    init(post: PregnancyPost, viewModel: PregnancyCommunityViewModel) {
        self.post = post
        self.viewModel = viewModel
        _editedContent = State(initialValue: post.content)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Post Header Section
                postHeaderSection
                
                // Content Section
                if isEditing {
                    editingSection
                } else {
                    contentSection
                }
                
                // Interaction Stats Section
                interactionSection
                
                Divider()
                    .padding(.vertical)
                
                // Comments Section
                commentsSection
                
                // Space for comment input
                Spacer(minLength: 60)
            }
        }
        .navigationBarTitle("Post", displayMode: .inline)
        .overlay(commentInputOverlay)
        .alert("Delete Post", isPresented: $showingDeleteAlert, actions: deleteAlert)
    }
    
    // MARK: - View Components
    
    // Post Header
    private var postHeaderSection: some View {
        HStack {
            // User Avatar
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "person.fill")
                    .foregroundColor(.gray))
            
            // User Info and Post Meta
            VStack(alignment: .leading) {
                Text(post.username)
                    .font(.headline)
                
                HStack {
                    Text(formatDate(post.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let week = post.weekNumber {
                        Text("•")
                            .foregroundColor(.gray)
                        Text("Week \(week)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Category Tag
            CategoryPill(category: post.category)
        }
        .padding(.horizontal)
    }
    
    // Editing Section
    private var editingSection: some View {
        VStack(spacing: 12) {
            TextEditor(text: $editedContent)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            HStack {
                Button("Cancel") {
                    isEditing = false
                    editedContent = post.content
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                Button("Save") {
                    viewModel.updatePost(post, newContent: editedContent)
                    isEditing = false
                }
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
    }
    
    // Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.content)
                .font(.body)
                .padding(.horizontal)
            
            if let imageData = post.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
    }
    
    // Interaction Stats
    private var interactionSection: some View {
        HStack(spacing: 20) {
            // Likes
            Button(action: { viewModel.likePost(post) }) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(post.likes)")
                        .font(.subheadline)
                }
            }
            
            // Comments Count
            HStack {
                Image(systemName: "bubble.left.fill")
                    .foregroundColor(.blue)
                Text("\(post.comments.count)")
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
    }
    
    // Comments Section
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comments")
                .font(.headline)
                .padding(.horizontal)
            
            if post.comments.isEmpty {
                NoCommentsView()
                    .padding(.top)
            } else {
                ForEach(post.comments) { comment in
                    DetailCommentRow(comment: comment)
                }
            }
        }
    }
    
    // Comment Input Overlay
    private var commentInputOverlay: some View {
        VStack {
            Spacer()
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
            .background(Color.white)
            .shadow(radius: 2)
        }
    }
    
    // Delete Alert
    @ViewBuilder
    private func deleteAlert() -> some View {
        Button("Delete", role: .destructive) {
            viewModel.deletePost(post)
            presentationMode.wrappedValue.dismiss()
        }
        Button("Cancel", role: .cancel) { }
    }
    
    // MARK: - Helper Functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Supporting ViewsFweek

// Category Pill View
struct CategoryPill: View {
    let category: PregnancyCategory
    
    var body: some View {
        Text(category.rawValue)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.1))
            .foregroundColor(.red)
            .cornerRadius(15)
    }
}

// Comment Row View
struct DetailCommentRow: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // User Avatar
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
                
                // Comment Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(comment.username)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(formatRelativeDate(comment.timestamp))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(comment.content)
                        .font(.subheadline)
                }
            }
            
            Divider()
        }
        .padding(.horizontal)
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// No Comments View
//struct NoCommentsView: View {
//    var body: some View {
//        VStack(spacing: 12) {
//            Image(systemName: "bubble.left")
//                .font(.system(size: 40))
//                .foregroundColor(.gray)
//            Text("No comments yet")
//                .font(.headline)
//                .foregroundColor(.gray)
//            Text("Be the first to comment!")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity, minHeight: 200)
//    }
//}

// Comment Input Area
//struct CommentInputArea: View {
//    @Binding var newComment: String
//    @FocusState var isFocused: Bool
//    let onSend: () -> Void
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            TextField("Write a comment...", text: $newComment)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .focused($isFocused)
//            
//            Button(action: onSend) {
//                Image(systemName: "arrow.up.circle.fill")
//                    .font(.title2)
//                    .foregroundColor(newComment.isEmpty ? .gray : .red)
//            }
//            .disabled(newComment.isEmpty)
//        }
//        .padding()
//        .background(Color(.systemGray6))
//    }
//}

// MARK: - Preview Provider
//struct CommunityPostDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            CommunityPostDetail(
//                post: PregnancyPost(
//                    id: "1",
//                    userId: "user1",
//                    username: "Test User",
//                    content: "Test post content",
//                    imageData: nil,
//                    weekNumber: 16,
//                    category: .weekByWeek,
//                    timestamp: Date(),
//                    likes: 0,
//                    comments: []
//                ),
//                viewModel: PregnancyCommunityViewModel()
//            )
//        }
//    }
//}

