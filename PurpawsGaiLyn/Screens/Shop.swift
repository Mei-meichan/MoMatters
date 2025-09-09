import Foundation
import SwiftUI
import SafariServices

// Product Model
struct Product: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var price: Double
    var imageURL: Image
    var productLink: String
}

// Shop View
struct Shop: View {
    @State private var searchText = ""
    @State private var selectedTab: Tab = .community // Track the selected tab

    // Example Products
    @State private var allProducts: [Product] = [
        Product(title: "Prenatal Vitamins", description: "Essential vitamins for pregnancy.", price: 321, imageURL: Image("vitamins"), productLink: "https://s.lazada.com.ph/s.oygIi"),
        Product(title: "Breastfeeding Bra", description: "Supportive bra for new mothers.", price: 89.99, imageURL: Image("bra"), productLink: "https://s.lazada.com.ph/s.oygE1"),
        Product(title: "Maternity Leggings", description: "Comfortable leggings for moms-to-be.", price: 112.69, imageURL: Image("Leggings"), productLink: "https://s.lazada.com.ph/s.oygy0"),
        Product(title: "Baby Monitor", description: "Monitor your baby safely from another room.", price: 999.99, imageURL: Image("Camera"), productLink: "https://s.lazada.com.ph/s.oygzh")
    ]
    
    enum Tab {
        case home
        case community
        case article
        case heart
        case profile
    }

    // Filtered products based on search text
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return allProducts
        } else {
            return allProducts.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        VStack {
                // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search products...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()

                // Product List
                ScrollView {
                    LazyVStack {
                        ForEach(filteredProducts) { product in
                            NavigationLink(destination: SafariView(url: URL(string: product.productLink)!)) {
                                ProductCard(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()

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
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true) // This hides the back button
        }
    }


// Product Card to display each product
struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Product Image
//                AsyncImage(url: URL(string: product.imageURL)) { phase in
//                    switch phase {
//                    case .success(let image):
                        product.imageURL
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                   
                    
                

                VStack(alignment: .leading, spacing: 5) {
                    Text(product.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(product.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Text("₱\(String(format: "%.2f", product.price))")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .bold()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

// Product Detail View
struct ProductDetailView: View {
    let product: Product

    var body: some View {
        VStack {
//            AsyncImage(url: URL(string: product.imageURL)) { phase in
//                switch phase {
//                case .success(let image):
            product.imageURL
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .padding()
                

            Text(product.title)
                .font(.title)
                .bold()
                .padding(.top, 10)

            Text(product.description)
                .font(.body)
                .foregroundColor(.gray)
                .padding()

            Spacer()

            Button(action: {
                if let url = URL(string: product.productLink) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Shop Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

struct SafariViewController: UIViewControllerRepresentable {

    var url: URL

    

    func makeUIViewController(context: Context) -> SFSafariViewController {

        return SFSafariViewController(url: url)

    }

    

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}

}

 
struct SafariView: View {

    let url: URL

    

    var body: some View {

        SafariViewController(url: url)

            .edgesIgnoringSafeArea(.all)

    }

}
