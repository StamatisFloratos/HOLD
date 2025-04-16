//
//  ProgressTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var tabManager: TabManager
    @State private var navigateToMeasurement = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex:"#10171F"),
                    Color(hex:"#466085")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    HStack {
                        Text("Welcome back")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("💪")
                            .font(.title)
                    }
                    .padding(.horizontal)
                    
                    // Training Progress Section
                    progressChart
                    
                    // Progress indicator
                    VStack(spacing: 10) {
                        HStack {
                            Spacer()
                            Text("You")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        // Triangle indicator
                        HStack {
                            Spacer()
                            Image(systemName: "triangle.fill")
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(180))
                            Spacer()
                        }
                        
                        // Progress slider visualization
                        ZStack(alignment: .leading) {
                            LinearGradient(
                                colors: [.orange, .yellow, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(height: 25)
                            .cornerRadius(12)
                        }
                        
                        // Time indicators
                        HStack {
                            Text("3 sec")
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("300 sec")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        
                        // Challenge section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("The Challenge")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            Text("Last Attempt: May 18, 2025")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)                    
                    Spacer(minLength: 80) // Space for tab bar
                }
            }
        }
        .navigationBarHidden(true)
        
    }
    
    var progressChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Training Progress")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            HStack {
                Text("All Time Best: 23 sec")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Weekly Best: 20 sec")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // Progress Chart
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(red: 0.1, green: 0.12, blue: 0.2))
                
                VStack(spacing: 10) {
                    Text("17 Mar - 23 Mar 2025")
                        .foregroundColor(.white)
                        .font(.callout)
                        .padding(.top, 10)
                    
                    // Line markers with labels
                    ZStack(alignment: .leading) {
                        VStack(alignment: .trailing, spacing: 30) {
                            HStack {
                                Spacer()
                                Text("24 sec")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Spacer()
                                Text("16 sec")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Spacer()
                                Text("8 sec")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Spacer()
                                Text("0 sec")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Chart bars
                        HStack(alignment: .bottom, spacing: 15) {
                            Bar(height: 0.65, day: "Mon")
                            Bar(height: 0.5, day: "Tue")
                            Bar(height: 0.8, day: "Wed")
                            Bar(height: 0.0, day: "Thu")
                            Bar(height: 0.0, day: "Fri")
                            Bar(height: 0.0, day: "Sat")
                            Bar(height: 0.0, day: "Sun")
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .frame(height: 150)
                    .padding(.horizontal)
                    
                    // Take Measurement Button
                    Button(action: {
                        // Handle measurement action
                        navigationManager.push(to: .measurementView)
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Take Measurement")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .padding()
                        .frame(maxWidth: .infinity,maxHeight: 47)
                        .background(Color(hex: "#FF1919"))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 15)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal)
        }
    }
}

// Bar component for the chart
struct Bar: View {
    let height: CGFloat
    let day: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 25, height: 100)
                
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 25, height: height * 100)
            }
            
            Text(day)
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}

#Preview {
    ProgressTabView()
        .environmentObject(TabManager())
}
