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
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 10) {
                ZStack {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.4)
                    VStack {
                        HStack{
                            Spacer()
                            Button {
                                onBack()
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
                .zIndex(1)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(item.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        Text(item.article)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .lineSpacing(5)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    KnowledgeDetailView(item: KnowledgeItem(id: "abc", title: "Hydration and Pelvic Health", imageName: "hydration-performance", article: "Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic Health.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health.vHydration and Pelvic HealthHydration and Pelvic HealthvHydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic Health.v.Hydration and Pelvic HealthHydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic Health.Hydration and Pelvic Health.v.Hydration and Pelvic Healthv.Hydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic HealthHydration and Pelvic Health"), onBack: {})
        
}
