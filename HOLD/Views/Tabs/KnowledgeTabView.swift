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
    @State var selectedItem: KnowledgeCategoryItem?
    @State var showKnowledgeCategory: Bool = false
    @State var selectedItems: [KnowledgeCategoryItem]?
    @State var selectedCategory: String?

    var body: some View {
        ZStack {
            AppBackground()
            
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
                        Spacer()
                        Text("Explore")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(hex: "#FFFFFF"), Color(hex: "#999999")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                        Spacer()
                    }
                    .padding(.vertical, 30)
                    
                    HStack {
                        Text("Knowledge")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(hex: "#FFFFFF"), Color(hex: "#999999")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                        Spacer()
                    }
                    .padding(.bottom,24)
                    .padding(.horizontal,28)
                    
                    ForEach(knowledgeViewModel.categories, id: \.id) { category in
                        KnowledgeSectionView(
                            title: category.categoryName,
                            items: category.categoryItems,
                            selectedItem: $selectedItem,
                            showKnowledgeCategory: $showKnowledgeCategory,
                            selectedItems: $selectedItems,
                            selectedCategory: $selectedCategory
                        )
                    }
                }
            }
            
            if showKnowledgeCategory {
                if let selectedItems = selectedItems, let category = selectedCategory {
                    KnowledgeView(categoryTitle: category, items: selectedItems, onBack: {
                        withAnimation {
                            showKnowledgeCategory = false
                        }
                    }, selectedItem: $selectedItem)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(1)
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: showKnowledgeCategory)
    }
}

// Reusable view for a knowledge section
struct KnowledgeSectionView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    let title: String
    let items: [KnowledgeCategoryItem]
    
    @Binding var selectedItem: KnowledgeCategoryItem?
    @Binding var showKnowledgeCategory: Bool
    @Binding var selectedItems: [KnowledgeCategoryItem]?
    @Binding var selectedCategory: String?
    @State var showKnowledgeDetailSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    selectedItems = items
                    selectedCategory = title
                    showKnowledgeCategory = true
                } label: {
                    HStack(spacing: 4) {
                        Text("See all")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom,24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    
                    Spacer().frame(width: 8)
                    
                    ForEach(items, id: \.id) { item in
                        Button {
                            print("Selected item: \(item.title)") // Debug print
                            selectedItem = item
                            showKnowledgeDetailSheet = true
                        } label: {
                            KnowledgeCardView(imageName: item.coverImage, title: item.title, description: item.subtitle, width: 135, height: 200)
                        }
                    }
                    
                    Spacer().frame(width: 8)
                }
                .padding(.bottom,24)
            }
        }
        .fullScreenCover(isPresented: $showKnowledgeDetailSheet) {
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

struct KnowledgeCardView: View {
    let imageName: String
    let title: String
    let description: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .center) {
            AsyncImage(url: URL(string: imageName)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: width, height: height)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: height)
                        .clipped()
                case .failure(_):
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: width, height: height)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.7))
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: width, height: height)
                }
            }

            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#666666").opacity(0.1), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                HStack {
                    Text(description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .padding(.top, 17)
            .padding(.bottom, 10)
        }
        .frame(width: width, height: height)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.25)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#FFFFFF"), Color(hex: "#999999")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    , lineWidth: 0.5)
        )
        .cornerRadius(16)
    }
}

#Preview {
    KnowledgeTabView()
        .environmentObject(NavigationManager())
        .environmentObject(TabManager())
        .environmentObject(KnowledgeViewModel())
}
