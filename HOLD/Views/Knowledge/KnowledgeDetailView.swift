//
//  KnowledgeDetailView.swift
//  HOLD
//
//  Created by Gemini on 08/04/25. // Adjust date/author
//

import SwiftUI

struct KnowledgeDetailView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    let item: KnowledgeItem
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    .ignoresSafeArea(edges: .top)
                VStack {
                    HStack{
                        Spacer()
                        Button {
                            navigationManager.goBack()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(item.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        Text(item.article)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .lineSpacing(5)
                        Spacer()
                        
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.6)
            .background(Color.white)
            
            .zIndex(1)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    KnowledgeDetailView(item: KnowledgeItem(id: "abc", title: "Hydration and Pelvic Health", imageName: "hydration_pelvic", article: "Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health"))
        
}
