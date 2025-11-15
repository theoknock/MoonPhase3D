//
//  ContentView.swift
//  MoonPhase3D
//
//  Created by Xcode Developer on 10/30/25.
//

import SwiftUI
import RealityKit
import WeatherKit
import CoreLocation
import Observation
import Combine

struct ContentView: View {
    @State private var moonViewModel = MoonViewModel()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color.indigo.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            MoonView(moonPhase: moonViewModel.moonPhase)
        }
        .ignoresSafeArea()
        
        //            VStack {
        // 3D Moon View
        //                MoonView(moonPhase: moonViewModel.moonPhase)
        //                    .frame(height: 400)
        //                    .padding()
        //                GeometryReader { geo in
        //            MoonView(moonPhase: moonViewModel.moonPhase)
        //                        .frame(
        //                            maxWidth: .infinity,
        //                            maxHeight: .infinity
        //                        )
        //                        .ignoresSafeArea()
        //                }
        // Prevent the GeometryReader from collapsing vertically:
        //                .scaledToFill()
        
        // Moon Phase Information
        VStack(spacing: 10) {
            Text("Current Moon Phase")
                .font(.headline)
                .foregroundColor(.white)
            
            if moonViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding()
            } else if let error = moonViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text(moonViewModel.phaseName)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Text("Illumination: \(Int(moonViewModel.illumination * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(15)
        .padding()
        .onAppear {
            moonViewModel.fetchMoonPhase()
        }
        
        
        // Test buttons for development
#if DEBUG
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach([
                    MoonPhase.new,
                    .waxingCrescent,
                    .firstQuarter,
                    .waxingGibbous,
                    .full,
                    .waningGibbous,
                    .lastQuarter,
                    .waningCrescent
                ], id: \.self) { phase in
                    Button(action: {
                        moonViewModel.setTestPhase(phase)
                    }) {
                        Text(phaseName(for: phase))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
#endif
    }
}
#if DEBUG
private func phaseName(for phase: MoonPhase) -> String {
    switch phase {
    case .new: return "New"
    case .waxingCrescent: return "Wax C"
    case .firstQuarter: return "1st Q"
    case .waxingGibbous: return "Wax G"
    case .full: return "Full"
    case .waningGibbous: return "Wan G"
    case .lastQuarter: return "Last Q"
    case .waningCrescent: return "Wan C"
    @unknown default: return "?"
    }
}
#endif

#Preview {
    ContentView()
        .preferredColorScheme(ColorScheme.dark)
}
