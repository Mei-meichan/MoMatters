import SwiftUI

struct HomeContentPage: View {
    var homeItem: HomeItem

     var body: some View {

         VStack {

 
            ScrollView {

                 VStack(spacing: 20) {


                     Image(homeItem.image)

                         .resizable()

                         .aspectRatio(contentMode: .fill)

                         .frame(height: 200)

                         .cornerRadius(10)
 
                     Text(homeItem.title)

                         .font(.headline)

                         .foregroundColor(.black)

                         .padding([.leading, .trailing], 8)

                     Text(homeItem.description)

                         .font(.body)

                         .foregroundColor(.gray)

                         .padding([.leading, .trailing, .bottom], 8)

                 }

                 .padding()

             }
 
            HStack {

                 Button(action: {

                     // Home action

                 }) {

                     Image(systemName: "house")

                         .font(.title)

                         .foregroundColor(Color.red) // Updated color

                 }

                 Spacer()

                 Button(action: {

                     // Like page action

                 }) {

                     Image(systemName: "heart")

                         .font(.title)

                         .foregroundColor(Color.red) // Updated color

                 }

                 Spacer()

                 Button(action: {

                     // Other action

                 }) {

                     Image(systemName: "list.bullet")

                         .font(.title)

                         .foregroundColor(Color.red) // Updated color

                 }

             }

             .padding()

         }

         .background(Color.white.edgesIgnoringSafeArea(.all)) // Updated color

         .navigationBarTitle("Momatters", displayMode: .inline)

     }

 }
