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
    @EnvironmentObject var knowledgeViewModel : KnowledgeViewModel

    @State var isClickedOnDetail = false
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
            
            
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                ScrollView(showsIndicators: false) {
                    
                    HStack {
                        Text("Knowledge")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.bottom,62)
                    
                    ForEach(knowledgeViewModel.sortedCategories, id: \.self) { category in
                        KnowledgeSectionView(title: category, items: knowledgeViewModel.groupedKnowledgeData[category] ?? [])
                    }
                }
            }
            .padding(.leading,14)
            .padding(.trailing,0)
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
        VStack(alignment: .leading) {
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
                .padding(.bottom,20)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items, id: \.id) { item in
                        Button {
                            navigationManager.push(to: .knowledgeDetailView(item: item))
                        } label: {
                            KnowledgeCardView(imageName: item.imageName, title: item.title, width: 139, height: 185)
                                .padding(.bottom,17)
                        }
                    }
                }
            }
        }
    }
}


// Reusable view for the knowledge cards
struct KnowledgeCardView: View {
    let imageName: String
    let title: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#666666").opacity(0.1), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(8)
        }
        .frame(width: width, height: height)
        .cornerRadius(15)
    }
}

#Preview {
    KnowledgeTabView()
        .environmentObject(KnowledgeViewModel())
}
