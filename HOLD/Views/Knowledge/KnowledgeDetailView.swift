//
//  KnowledgeDetailView.swift
//  HOLD
//
//  Created by Gemini on 08/04/25. // Adjust date/author
//

import SwiftUI

struct KnowledgeDetailView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    let item: KnowledgeCategoryItem
    var onBack: () -> Void
    
    @State private var currentStep = 1
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    @State private var isPaused = false
    @State private var isLoading = true
    @State private var loadedImages: [String: UIImage] = [:]
    
    private var totalSteps: Int {
        return 1 + item.slides.count
    }
    
    let stepDuration: TimeInterval = 5.0
    let timerInterval: TimeInterval = 0.01
    
    var allImageURLs: [String] {
        var urls = [item.coverImage]
        urls.append(contentsOf: item.slides.map { $0.image })
        return urls
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                Color.black.ignoresSafeArea(.container, edges: .bottom)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.0)
                    .padding(40)
            } else {
                backgroundImage
                    .ignoresSafeArea(.container, edges: .bottom)
                
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#666666").opacity(0.1), Color.black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(.container, edges: .bottom)
                
                VStack {
                    ProgressBar(currentStep: currentStep, totalSteps: totalSteps, progress: progress)
                        .padding(.top, 25)
                    
                    Spacer()
                    
                    ZStack {
                        if currentStep == 1 {
                            contentCover(title: item.title, subtitle: item.subtitle)
                                .opacity(1)
                        }
                        ForEach(Array(item.slides.enumerated()), id: \.element.id) { index, slide in
                            contentSlide(title: slide.header, subtitle: slide.content)
                                .opacity(currentStep == (index + 2) ? 1 : 0)
                        }
                    }
                }
                .onAppear {
                    startProgress()
                }
                .onDisappear {
                    timer?.invalidate()
                }
                .overlay(
                    HStack(spacing: 0) {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if currentStep > 1 {
                                    triggerHaptic()
                                    goToPreviousStep()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width / 5)
                        
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: UIScreen.main.bounds.width / 5)
                        
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: UIScreen.main.bounds.width / 5)
                        
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: UIScreen.main.bounds.width / 5)
                        
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if currentStep < totalSteps {
                                    triggerHaptic()
                                    goToNextStep()
                                } else {
                                    triggerHaptic()
                                    onBack()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width / 5)
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .animation(nil, value: currentStep)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPaused {
                        pauseProgress()
                    }
                }
                .onEnded { _ in
                    if isPaused {
                        resumeProgress()
                    }
                }
        )
        .onAppear {
            preloadAllImages()
        }
    }
    
    // MARK: - Preload Images
    private func preloadAllImages() {
        let urls = allImageURLs.compactMap { URL(string: $0) }
        let group = DispatchGroup()
        var loaded: [String: UIImage] = [:]
        for url in urls {
            group.enter()
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    loaded[url.absoluteString] = image
                }
                group.leave()
            }
            task.resume()
        }
        DispatchQueue.global().async {
            group.wait()
            DispatchQueue.main.async {
                self.loadedImages = loaded
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Content Cover
    private func contentCover(title: String, subtitle: String) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text(title)
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 24)
            
            Spacer()
            
            HStack {
                Text(subtitle)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Content Slide
    private func contentSlide(title: String, subtitle: String) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text(title)
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 37)
            
            Spacer()
            
            HStack {
                Text(subtitle)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.leading, 32)
            .padding(.trailing, 24)
            .padding(.bottom, 30)
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Dynamic Background
    private var backgroundImage: some View {
        Group {
            if currentStep == 1 {
                // Cover slide - use preloaded image
                if let uiImage = loadedImages[item.coverImage] {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
            } else {
                // Content slide - use slide image
                let slideIndex = currentStep - 2
                if slideIndex < item.slides.count {
                    let url = item.slides[slideIndex].image
                    if let uiImage = loadedImages[url] {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.black)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.7))
                            )
                    }
                } else {
                    Rectangle()
                        .fill(Color.black)
                }
            }
        }
    }
    
    // MARK: - Progress Management
    private func startProgress() {
        progress = 0
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { t in
            if !isPaused {
                progress += CGFloat(timerInterval / stepDuration)
                if progress >= 1.0 {
                    progress = 1.0
                    t.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if currentStep < totalSteps {
                            triggerHaptic()
                            currentStep += 1
                            startProgress()
                        } else {
                            triggerHaptic()
                            onBack()
                        }
                    }
                }
            }
        }
    }
    
    private func pauseProgress() {
        isPaused = true
    }
    
    private func resumeProgress() {
        isPaused = false
    }
    
    private func goToNextStep() {
        if currentStep < totalSteps {
            currentStep += 1
            progress = 0.0
            startProgress()
        }
    }
    
    private func goToPreviousStep() {
        if currentStep > 1 {
            currentStep -= 1
            progress = 0.0
            startProgress()
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    KnowledgeDetailView(
        item: KnowledgeCategoryItem(
            title: "Sample Title",
            subtitle: "Sample subtitle for the knowledge item",
            coverImage: "https://example.com/cover.jpg",
            slides: [
                KnowledgeDetail(image: "https://example.com/slide1.jpg", content: "Slide 1 content", header: "Hello"),
                KnowledgeDetail(image: "https://example.com/slide2.jpg", content: "Slide 2 content", header: "Hello")
            ]
        ),
        onBack: {}
    )
    .environmentObject(NavigationManager())
}
