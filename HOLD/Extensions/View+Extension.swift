//
//  View+Extension.swift
//  ShowMe
//
//  Created by Rabbia Ijaz on 08/09/2024.
//

import Foundation
import SwiftUI

extension View {
    
    func embedNavigationStack() -> some View {
        modifier(EmbedNavigationViewModifier(view: AnyView(self)))
    }
    
    func embedNavigationStackWithPath(path: Binding<[NavigationManager.Route]>) -> some View {
        modifier(EmbedNavigationStackPathModifier(view: AnyView(self), path: path))
    }
    
    func eraseToolbarForView() -> some View {
        modifier(EraseToolbarForView(view: AnyView(self)))
    }
    
    func conditionalProgressView(isPresented: Binding<Bool>) -> some View {
        self.modifier(ConditionalProgressViewModifier(isPresented: isPresented))
    }
    
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct EmbedNavigationViewModifier: ViewModifier {
    let view: AnyView
    
    func body(content: Content) -> some View {
        NavigationStack {
            view
                .navigationBarBackButtonHidden()
                .toolbar(.hidden)
        }
    }
}

private struct EmbedNavigationStackPathModifier: ViewModifier {
    let view: AnyView
    @Binding var path: [NavigationManager.Route]
    
    func body(content: Content) -> some View {
        NavigationStack(path: $path) {
            view
                .navigationBarBackButtonHidden()
                .toolbar(.hidden)
        }
    }
}

private struct EraseToolbarForView: ViewModifier {
 
    let view: AnyView
    
    func body(content: Content) -> some View {
        view
            .navigationBarBackButtonHidden()
            .toolbar(.hidden)
    }
    
}

struct ConditionalProgressViewModifier: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        Group {
            if isPresented {
                ZStack {
                    content
                    
                    ProgressView()
                        .scaleEffect(CGSize(width: 2.0, height: 2.0))
                }

            } else {
                content
            }
        }
    }
}
