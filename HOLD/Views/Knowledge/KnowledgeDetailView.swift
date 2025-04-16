//
//  KnowledgeDetailView.swift
//  HOLD
//
//  Created by Gemini on 08/04/25. // Adjust date/author
//

import SwiftUI

struct KnowledgeDetailView: View {
    let item: KnowledgeItem

    // Environment variable to dismiss the view (common for modals/sheets)
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: NavigationManager

    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    Image("knowledgePlaceholder")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.4)
                        .ignoresSafeArea(edges: .top)
                    VStack {
                        HStack{
                            Spacer()
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.black.opacity(0.3))
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
                .zIndex(0)
                
                ZStack{
                    LinearGradient(
                        colors: [
                            Color(hex:"#10171F"),
                            Color(hex:"#466085")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    VStack(alignment: .leading, spacing: 15) {
                        Text(item.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        Text(item.longText)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .lineSpacing(5)
                        Spacer()
                        
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.6)
                .background(Color.white)
                
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    KnowledgeDetailView(item: KnowledgeItem(title: "Hydration and Pelvic Health", imageName: "hydration_pelvic", shortDescription: "Desc 1", longText: "Long text 1"))
        
}
