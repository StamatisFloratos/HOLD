//
//  KnowledgeTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct KnowledgeTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var tabManager: TabManager
    
    // --- Data Loading and Grouping ---
    @StateObject private var viewModel = KnowledgeViewModel()
    
   
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex:"#10171F"),
                    Color(hex:"#466085")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Logo at the top
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    HStack {
                        Text("Knowledge")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    ForEach(viewModel.sortedCategories, id: \.self) { category in
                        KnowledgeSectionView(title: category, items: viewModel.groupedKnowledgeData[category] ?? [])
                    }
                    
                    
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer(minLength: 80) // Space for tab bar
            }
        }
        .navigationBarHidden(true)
    }
}

// Reusable view for a knowledge section
struct KnowledgeSectionView: View {
    let title: String
    // Placeholder: You'll pass actual items here later
    let items: [KnowledgeItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section Title with Chevron
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }

            // Horizontal ScrollView for Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items, id: \.self) { item in
                        KnowledgeCardView(imageName: "knowledgePlaceholder", title: item.title)
                    }
                }
                .padding(.vertical, 5) // Add small vertical padding
            }
        }
    }
}

// Reusable view for the knowledge cards
struct KnowledgeCardView: View {
    // Placeholder properties - replace with your actual data model later
    let imageName: String// <<< MUST HAVE THIS IMAGE IN ASSETS
    let title: String// Example title

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder image - replace with actual image loading
            Image(imageName) // Make sure you have an image named "placeholder_couple" in your assets
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 200) // Adjust size as needed
                .clipped() // Clip the image to the frame bounds

            // Gradient overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.9), Color.clear]),
                startPoint: .bottom,
                endPoint: .center
            )

            // Text title
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(10) // Padding for the text inside the card
        }
        .frame(width: 150, height: 200) // Match the image frame
        .cornerRadius(15)
        // .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2) // Optional subtle shadow
    }
}

#Preview {
    KnowledgeTabView()
}
