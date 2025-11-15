//
//  MoonViewModel.swift
//  MoonPhase3D
//
//  Created by Xcode Developer on 10/30/25.
//

import Foundation
import WeatherKit
import CoreLocation
import Observation
import Combine

@Observable
@MainActor
final class MoonViewModel: NSObject, CLLocationManagerDelegate {
    var moonPhase: MoonPhase = .waxingGibbous
    var phaseName: String = "Loading..."
    var illumination: Double = 0.0
    var coordinates: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let weatherService = WeatherService.shared
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func fetchMoonPhase() {
        // Request location permission
        locationManager.requestWhenInUseAuthorization()
        
        guard let location = locationManager.location else {
            errorMessage = "Unable to get current location."
            return
        }
        
        self.coordinates = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        
        Task {
            await fetchWeatherData(for: location)
        }
    }
    
    @MainActor
    private func fetchWeatherData(for location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch the daily forecast which includes moon phase
            let weather = try await weatherService.weather(
                for: location,
                including: .daily
            )
            
            // Get today's forecast (first element in the array)
            if let todayWeather = weather.forecast.first {
                self.moonPhase = todayWeather.moon.phase
                self.phaseName = getMoonPhaseName(todayWeather.moon.phase)
                
                // Calculate illumination based on phase fraction
                // MoonPhase doesn't have a fraction property, so we calculate it
                let fraction = calculateMoonFraction(todayWeather.moon.phase)
                self.illumination = fraction
                
                // Convert fraction to illumination percentage
                // At 0.0 and 1.0 (new moon), illumination is 0%
                // At 0.5 (full moon), illumination is 100%
                if fraction <= 0.5 {
                    self.illumination = fraction * 2.0  // 0 to 0.5 maps to 0% to 100%
                } else {
                    self.illumination = 2.0 - (fraction * 2.0)  // 0.5 to 1.0 maps to 100% to 0%
                }
                
                print("Moon phase fetched successfully: \(self.phaseName)")
                print("Moon phase fraction: \(fraction)")
                print("Illumination: \(self.illumination * 100)%")
                
                // Optional: Get moonrise and moonset times
                if let moonrise = todayWeather.moon.moonrise {
                    print("Moonrise: \(moonrise)")
                }
                if let moonset = todayWeather.moon.moonset {
                    print("Moonset: \(moonset)")
                }
            }
            
        } catch let error as NSError {
            // Handle specific WeatherKit errors
            switch error.code {
            case 1:
                errorMessage = "WeatherKit not available. Please check your entitlements."
            case 2:
                errorMessage = "Location not available or invalid."
            case 3:
                errorMessage = "Network error. Please check your connection."
            default:
                errorMessage = "Error fetching weather: \(error.localizedDescription)"
            }
            
            print("WeatherKit error: \(error)")
            self.phaseName = "Error"
        }
        
        isLoading = false
    }
    
    // Calculate moon fraction based on the phase enum
    private func calculateMoonFraction(_ phase: MoonPhase) -> Double {
        // Estimate the fraction value based on the moon phase
        // This represents the progression through the lunar cycle (0.0 to 1.0)
        switch phase {
        case .new:
            return 0.0  // New moon
        case .waxingCrescent:
            return 0.125  // Between new and first quarter
        case .firstQuarter:
            return 0.25  // First quarter
        case .waxingGibbous:
            return 0.375  // Between first quarter and full
        case .full:
            return 0.5  // Full moon
        case .waningGibbous:
            return 0.625  // Between full and last quarter
        case .lastQuarter:
            return 0.75  // Last quarter
        case .waningCrescent:
            return 0.875  // Between last quarter and new
        @unknown default:
            return 0.0
        }
    }
    
    private func getMoonPhaseName(_ phase: MoonPhase) -> String {
        switch phase {
        case .new:
            return "New Moon"
        case .waxingCrescent:
            return "Waxing Crescent"
        case .firstQuarter:
            return "First Quarter"
        case .waxingGibbous:
            return "Waxing Gibbous"
        case .full:
            return "Full Moon"
        case .waningGibbous:
            return "Waning Gibbous"
        case .lastQuarter:
            return "Last Quarter"
        case .waningCrescent:
            return "Waning Crescent"
        @unknown default:
            return "Unknown"
        }
    }
    
    private func getMoonIllumination(_ phase: MoonPhase) -> Double {
        // Calculate actual illumination based on moon phase
        let fraction = calculateMoonFraction(phase)
        
        // Convert fraction to illumination
        // New moon (0.0) = 0% illumination
        // Full moon (0.5) = 100% illumination
        // New moon (1.0) = 0% illumination
        if fraction <= 0.5 {
            return fraction * 2.0
        } else {
            return 2.0 - (fraction * 2.0)
        }
    }
    
    // For testing without WeatherKit (useful during development)
    func setTestPhase(_ phase: MoonPhase) {
        self.moonPhase = phase
        self.phaseName = getMoonPhaseName(phase)
        self.illumination = getMoonIllumination(phase)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission granted, fetch with current location
            if let location = manager.location {
                self.coordinates = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
                Task {
                    await fetchWeatherData(for: location)
                }
            }
        case .denied, .restricted:
            errorMessage = "Location access denied. Using default location."
            // Use default location
            let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
            self.coordinates = "\(defaultLocation.coordinate.latitude), \(defaultLocation.coordinate.longitude)"
            Task {
                await fetchWeatherData(for: defaultLocation)
            }
        default:
            break
        }
    }
}

// Extension for preview/testing
extension MoonViewModel {
    static var preview: MoonViewModel {
        let model = MoonViewModel()
        model.moonPhase = .waxingGibbous
        model.phaseName = "Waxing Gibbous"
        model.illumination = 0.75
        return model
    }
}
