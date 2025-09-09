import SwiftUI

struct ArticleDetailPage: View {
    let article: Article
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                    
                    // Header Image (Optional: Only if the article has an image)
                    if let imageUrlString = article.urlToImage,
                       let imageUrl = URL(string: imageUrlString) {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 250)
                                    .clipped()
                            default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 250)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // Title
                        Text(article.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(3) // Ensures title does not overflow
                            .padding(.bottom, 8)
                        
                        // Article Meta Info (Source & Published Date)
                        HStack {
                            Text(article.source.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatDate(article.publishedAt))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 8)
                        
                        Divider()
                        
                        // Description
                        if let description = article.description {
                            Text(description)
                                .font(.body)
                                .lineSpacing(8)
                                .padding(.bottom, 16) // Added space after description
                                .fixedSize(horizontal: false, vertical: true) // Ensure text wraps correctly
                        }
                        
                        // Content
                        if let content = article.content {
                            Text(content)
                                .font(.body)
                                .lineSpacing(8)
                                .fixedSize(horizontal: false, vertical: true) // Allow content to expand vertically
                                .padding(.bottom, 16) // Space after content
                        }
                        
                        // Link to Full Article
                        Link(destination: URL(string: article.url)!) {
                            Text("Read full article")
                                .font(.headline)
                                .foregroundColor(Color(red: 244/255, green: 83/255, blue: 138/255)) // Custom color for the link
                        }
                        .padding(.top, 8)
                        .padding([.top, .bottom], 16) // Padding around the link
                    }
                    .padding([.leading, .trailing]) // General padding for content
                }
                .padding(.top) // Padding for top of ScrollView
               
            }
        .navigationBarTitle("Article Detail", displayMode: .inline) // Title of the navigation bar
    }
    
    // Format date to a readable format
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy" // Desired date format
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString // Return the original string if date conversion fails
    }
}

