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
    @State var selectedItem: KnowledgeItem?
    @State var showKnowledgeCategory: Bool = false
    @State var selectedItems: [KnowledgeItem]?
    @State var selectedCategory: String?

    var body: some View {
        ZStack {
            AppBackground()
            
            if showKnowledgeCategory {
                if let selectedItems = selectedItems, let category = selectedCategory {
                    KnowledgeView(categoryTitle: category, items: selectedItems, onBack: {
                        withAnimation {
                            showKnowledgeCategory = false
                        }
                    }, selectedItem: $selectedItem)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
                }
            } else {
                VStack(spacing:0) {
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
                            KnowledgeSectionView(
                                title: category,
                                items: knowledgeViewModel.groupedKnowledgeData[category] ?? [],
                                selectedItem: $selectedItem,
                                showKnowledgeCategory: $showKnowledgeCategory,
                                selectedItems: $selectedItems,
                                selectedCategory: $selectedCategory
                            )
                        }
                    }
                    .padding(.leading,14)
                    .padding(.trailing,0)
                }
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
    
    @Binding var selectedItem: KnowledgeItem?
    @Binding var showKnowledgeCategory: Bool
    @Binding var selectedItems: [KnowledgeItem]?
    @Binding var selectedCategory: String?
    @State var showKnowledgeDetailSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            Button {
                selectedItems = items
                selectedCategory = title
                showKnowledgeCategory = true
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
                            print("Selected item: \(item.title)") // Debug print
                            selectedItem = item
                            showKnowledgeDetailSheet = true
                        } label: {
                            KnowledgeCardView(imageName: item.imageName, title: item.title, width: 139, height: 185)
                                .padding(.bottom,17)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showKnowledgeDetailSheet) {
            if let item = selectedItem {
                KnowledgeDetailView(item: item, onBack: {
                    withAnimation {
                        showKnowledgeDetailSheet = false
                        showKnowledgeCategory = false
                    }
                })
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
