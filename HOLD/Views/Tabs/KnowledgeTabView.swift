//
//  KnowledgeTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

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
                                colors: [Color(hex: "#FFFFFF"), Color(hex: "#FFFFFF"), Color(hex: "#999999")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                        Spacer()
                    }
                    .padding(.vertical, 35)
                    
                    ZStack(alignment: .center) {
                        Image("KegelTutorialBanner")
                            .resizable()
                            .frame(height: 245)
                            .cornerRadius(20)
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                            ZStack(alignment: .bottom) {
                                VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, alpha: 0.9)
                                    .frame(height: 100)
                                HStack {
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        
                                        Text("Learn How to Do Kegels")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(LinearGradient(
                                                colors: [Color(hex: "#FFFFFF"), Color(hex: "#FFFFFF"), Color(hex: "#FFFFFF"), Color(hex: "#999999")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ))
                                        
                                        Spacer().frame(height: 8)
                                        
                                        Text("Retry the tutorial that helps you understand how to use your pelvic floor muscles")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                    
                                    Button(action: {
                                        triggerHaptic()
                                        knowledgeViewModel.showOnboardingTutorial = true
                                        
                                    }) {
                                        Text("Start")
                                            .font(.system(size: 16, weight: .semibold))
                                            .frame(width: 82, height: 40, alignment: .center)
                                            .background(Color(hex: "#FF1919"))
                                            .foregroundColor(.white)
                                            .cornerRadius(30)
                                    }
                                }
                                .padding(.leading, 15)
                                .padding(.trailing, 20)
                            }
                            .frame(height: 100)
                        }
                    }
                    .frame(height: 245)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 0.5)
                    )
                    .padding(.bottom, 45)
                    .padding(.horizontal,28)
                    
                    HStack {
                        Text("Knowledge")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(hex: "#FFFFFF"), Color(hex: "#FFFFFF"), Color(hex: "#999999")],
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
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
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
            WebImage(url: URL(string: imageName)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.black)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
            .onSuccess { _, _, _ in }
            .onFailure { error in
                print("Failed to load image: \(error)")
            }
            .indicator(Indicator.activity)
            .transition(AnyTransition.fade(duration: 0.3))
            .frame(width: width, height: height)
            .clipped()

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
