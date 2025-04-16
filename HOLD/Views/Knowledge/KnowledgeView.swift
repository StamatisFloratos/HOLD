//
//  KnowledgeView.swift
//  HOLD
//
//  Created by Gemini on 08/04/25. // Adjust date/author
//

import SwiftUI

struct KnowledgeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    let categoryTitle: String
    let items: [KnowledgeItem]

    // Define grid layout: 2 columns, adaptive spacing
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

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
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                HStack {
                    Button {
                        navigationManager.goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .bold))
                        Text(categoryTitle)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()
                                    
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 15)
                
                // --- Grid Content ---
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) { // Spacing between rows
                        ForEach(items) { item in
                            // Use the existing card view
                            Button {
                                navigationManager.push(to: .knowledgeDetailView(item: item))
                            } label: {
                                KnowledgeCardView(imageName: "knowledgePlaceholder", title: item.title)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    // Example items for previewing the "Nutrition" category
    let previewItems = [
        KnowledgeItem(title: "Hydration and Pelvic Health", imageName: "hydration_pelvic", shortDescription: "Desc 1", longText: "Long text 1"),
        KnowledgeItem(title: "Placeholder Nutrition 1", imageName: "placeholder_couple", shortDescription: "Desc 2", longText: "Long text 2"),
        KnowledgeItem(title: "Placeholder Nutrition 2", imageName: "placeholder_couple", shortDescription: "Desc 3", longText: "Long text 3"),
        KnowledgeItem(title: "Placeholder Nutrition 4", imageName: "placeholder_couple", shortDescription: "Desc 4", longText: "Long text 4")
    ]

    return KnowledgeView(categoryTitle: "Nutrition", items: previewItems)
        .environmentObject(NavigationManager()) // Provide dummy manager for preview
        .preferredColorScheme(.dark)
}
