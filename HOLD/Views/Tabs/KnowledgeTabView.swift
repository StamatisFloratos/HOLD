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
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    Text("Knowledge")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    ForEach(viewModel.sortedCategories, id: \.self) { category in
                        KnowledgeSectionView(title: category, items: viewModel.groupedKnowledgeData[category] ?? [])
                    }
                }
                .padding(.horizontal)
                Spacer(minLength: 80)
            }
        }
        .navigationBarHidden(true)
    }
}

// Reusable view for a knowledge section
struct KnowledgeSectionView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    let title: String
    let items: [KnowledgeItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                navigationManager.push(to: .knowledgeView(categoryTitle: title, items: items))
            } label: {
                HStack {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items, id: \.self) { item in
                        Button {
                            navigationManager.push(to: .knowledgeDetailView(item: item))
                        } label: {
                            KnowledgeCardView(imageName: "knowledgePlaceholder", title: item.title)
                        }

                       
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
}

// Reusable view for the knowledge cards
struct KnowledgeCardView: View {
    let imageName: String
    let title: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 200)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.9), Color.clear]),
                startPoint: .bottom,
                endPoint: .center
            )

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(10)
        }
        .frame(width: 150, height: 200)
        .cornerRadius(15)
//         .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2) // Optional subtle shadow
    }
}

#Preview {
    KnowledgeTabView()
}
