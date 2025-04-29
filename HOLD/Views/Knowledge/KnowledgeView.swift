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

            VStack {
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
                .padding(.horizontal,13)
                .padding(.top, 10)
                .padding(.bottom, 15)
                
                // --- Grid Content ---
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 54) { // Spacing between rows
                        ForEach(items) { item in
                            // Use the existing card view
                            Button {
                                navigationManager.push(to: .knowledgeDetailView(item: item))
                            } label: {
                                KnowledgeCardView(imageName: item.imageName, title: item.title, width: 139, height: 185 )
                            
                            }
                        }
                    }
                    .padding(.horizontal,35)
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
  
    let knowledgeViewModel = KnowledgeViewModel()
    if let items = knowledgeViewModel.groupedKnowledgeData["Nutrition"]  {
        KnowledgeView(categoryTitle: "Nutrition", items: items)
            .environmentObject(NavigationManager()) // Provide dummy manager for preview
            .environmentObject(KnowledgeViewModel())
    }
}
