
import SwiftUI

// MARK: - Models
struct Article: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let description: String?
    let urlToImage: String?
    let publishedAt: String
    let source: Source
    let url: String
    let content: String?
    
    
    struct Source: Decodable {
        let name: String
    }
}

struct NewsResponse: Decodable {
    let articles: [Article]
}

enum ArticleCategory: String, CaseIterable {
    case latest = "Latest Parenting News"
    case education = "Child Education"
    case pregnancy = "Pregnancy & Birth"
    case parenting = "Parenting Tips"
    case relationship = "Family Relationships"
    case lifestyle = "Family Lifestyle"

    
    var searchQuery: String {
        switch self {
        case .latest: return "parenting family children"
        case .education: return "child education learning development school"
        case .pregnancy: return "pregnancy birth expecting mother"
        case .parenting: return "parenting advice children development"
        case .relationship: return "family relationships parenting marriage"
        case .lifestyle: return "family lifestyle parenting work balance"
    
        }
    }
}

// MARK: - ViewModel
class ArticlesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var selectedCategory: ArticleCategory = .latest
    
    private let apiKey = "77a6aad9da65407a9a9bb55d0242ef6f"
    
    func fetchArticles(for category: ArticleCategory) {
        isLoading = true
        selectedCategory = category
        
        let baseUrl = "https://newsapi.org/v2/everything"
        let query = category.searchQuery
        let urlString = "\(baseUrl)?q=\(query)&sortBy=publishedAt&language=en&apiKey=\(apiKey)"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data,
                      let response = try? JSONDecoder().decode(NewsResponse.self, from: data) else {
                    return
                }
                
                self?.articles = response.articles
            }
        }.resume()
    }
}



// MARK: - Views
struct ArticlesPage: View {
    @StateObject private var viewModel = ArticlesViewModel()
    @State private var selectedArticle: Article?
    @State private var searchText = ""
    @State private var navigateToProfile = false // For profile navigation
    @State private var selectedTab: Tab = .article // Track the selected tab
    
    enum Tab {
        case home
        case community
        case article
        case heart
        case profile
    }
    
    var filteredArticles: [Article] {
        if searchText.isEmpty {
            return viewModel.articles
        }
        return viewModel.articles.filter {
            $0.title.lowercased().contains(searchText.lowercased()) ||
            $0.description?.lowercased().contains(searchText.lowercased()) ?? false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search articles...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()
            
            // Category Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ArticleCategory.allCases, id: \.self) { category in
                        Button(action: {
                            viewModel.fetchArticles(for: category)
                        }) {
                            Text(category.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(viewModel.selectedCategory == category ? (Color(red: 255/255, green: 78/255, blue: 104/255)) : Color.gray.opacity(0.2))
                                .foregroundColor(viewModel.selectedCategory == category ? .white : .black)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            // Articles List
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading articles...")
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredArticles) { article in
        
                            NavigationLink(destination: ArticleDetailPage(article: article)) {
                                                          ArticleCard(article: article)
                                                      }
                        }
                    }
                    .padding()
                }
            }
            // Bottom Navigation Bar
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
            
            
            
            
            
        }
        .navigationBarTitle("Family Articles", displayMode: .inline)
        .onAppear {
            if viewModel.articles.isEmpty {
                viewModel.fetchArticles(for: .latest)
            }
        }
        .sheet(item: $selectedArticle) { article in
            ArticleDetailPage(article: article)
        }
    }
}

struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Article Image
            if let imageUrlString = article.urlToImage,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                    }
                }
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let description = article.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                HStack {
                    Text(article.source.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(formatDate(article.publishedAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}
