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
    var onBack: () -> Void
    @Binding var selectedItem: KnowledgeItem?
    @State var showKnowledgeDetailSheet = false

    // Define grid layout: 2 columns, adaptive spacing
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
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
                    LazyVGrid(columns: columns, spacing: 54) {
                        ForEach(items) { item in
                            Button {
                                selectedItem = item
                                showKnowledgeDetailSheet = true
                            } label: {
                                KnowledgeCardView(imageName: item.imageName, title: item.title, width: 139, height: 185)
                            }
                        }
                    }
                    .padding(.horizontal,35)
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showKnowledgeDetailSheet) {
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
//    let knowledgeViewModel = KnowledgeViewModel()
//    Group {
//        if let items = knowledgeViewModel.groupedKnowledgeData["Nutrition"] {
//            KnowledgeView(categoryTitle: "Nutrition", items: items, onBack: {}, selectedItem: $Knowledge)
//                .environmentObject(NavigationManager())
//                .environmentObject(knowledgeViewModel)
//        } else {
//            Text("Loading...")
//        }
//    }
}
