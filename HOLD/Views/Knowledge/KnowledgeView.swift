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
    let items: [KnowledgeCategoryItem]
    var onBack: () -> Void
    @Binding var selectedItem: KnowledgeCategoryItem?
    @State var showKnowledgeDetailSheet = false

    // Define grid layout: 2 columns, adaptive spacing
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 45),
        GridItem(.flexible(), spacing: 45)
    ]

    var body: some View {
        ZStack {
            AppBackground()

            VStack {
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                HStack {
                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .medium))
                        Text(categoryTitle)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(hex: "#FFFFFF"), Color(hex: "#FFFFFF"), Color(hex: "#999999")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    }

                    Spacer()
                }
                .padding(.horizontal,28)
                .padding(.top, 10)
                .padding(.bottom, 36)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 35) {
                        ForEach(items) { item in
                            Button {
                                selectedItem = item
                                showKnowledgeDetailSheet = true
                            } label: {
                                KnowledgeCardView(imageName: item.coverImage, title: item.title, description: item.subtitle, width: 135, height: 200)
                            }
                        }
                    }
                    .padding(.horizontal,40)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showKnowledgeDetailSheet) {
            if let item = selectedItem {
                KnowledgeDetailView(item: item, onBack: {
                    withAnimation {
                        showKnowledgeDetailSheet = false
                    }
                })
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedItem: KnowledgeCategoryItem? = nil
    
    return KnowledgeView(
        categoryTitle: "Nutrition",
        items: [],
        onBack: {},
        selectedItem: $selectedItem
    )
    .environmentObject(NavigationManager())
    .environmentObject(KnowledgeViewModel())
}
