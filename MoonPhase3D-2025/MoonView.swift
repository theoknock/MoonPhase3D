//
//  MoonView.swift
//  MoonPhase3D
//
//  Created by Xcode Developer on 10/30/25.
//

import Foundation
import SwiftUI
import RealityKit
import WeatherKit

struct MoonView: UIViewRepresentable {
    let moonPhase: MoonPhase
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Create an anchor for our moon
        let anchor = AnchorEntity()
        arView.scene.addAnchor(anchor)
        
        // Create the moon sphere
        let moonEntity = createMoon()
        anchor.addChild(moonEntity)
        
        // Set up the camera
        setupCamera(arView: arView)
        
        // Store the moon entity in the context for updates
        context.coordinator.moonEntity = moonEntity
        context.coordinator.arView = arView
        
        arView.cameraMode = .nonAR
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update lighting based on moon phase
        updateMoonPhase(context.coordinator.moonEntity, arView: context.coordinator.arView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func createMoon() -> ModelEntity {
        // Load the moon model from a .usdz file exported from Reality Composer Pro
        var moonEntity: ModelEntity
        if let loadedEntity = try? Entity.loadModel(named: "Moon") {
            loadedEntity.scale = SIMD3(6.0)
            moonEntity = loadedEntity
            moonEntity.position = [0, 0, -0.5]
        } else if let url = Bundle.main.url(forResource: "Moon", withExtension: "usdz"),
                  let loadedEntity = try? Entity.loadModel(contentsOf: url) {
            loadedEntity.scale = SIMD3(0.001, 0.001, 0.001)
            moonEntity = loadedEntity
        } else {
            // Fallback sphere if loading fails
            let fallbackMesh = MeshResource.generateSphere(radius: 100.0)
            let fallbackMaterial = SimpleMaterial(color: .gray, isMetallic: false)
            moonEntity = ModelEntity(mesh: fallbackMesh, materials: [fallbackMaterial])
        }
        return moonEntity
    }
    
    private func setupCamera(arView: ARView) {
        // Disable default camera controls
        arView.cameraMode = .nonAR
        
        // Create a perspective camera
        let cameraEntity = PerspectiveCameraComponent()
        
        // Set up the camera anchor
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.position = [0, 0, 0.5]
        
        arView.scene.addAnchor(cameraAnchor)
    }
    
    private func updateMoonPhase(_ moonEntity: ModelEntity?, arView: ARView?) {
        guard let moonEntity = moonEntity, let arView = arView else { return }
        
        // Remove existing lights
        arView.scene.anchors.forEach { anchor in
            anchor.children.forEach { entity in
                if entity is DirectionalLight || entity is PointLight {
                    entity.removeFromParent()
                }
            }
        }
        
        // Create lighting based on moon phase
        let lightAnchor = AnchorEntity()
        arView.scene.addAnchor(lightAnchor)
        
        // Get the phase angle in radians
        let phaseAngleRadians = getMoonPhaseAngle(moonPhase)
        
        // Calculate light position - the sun moves around the moon
        // For new moon, sun is behind the moon (from viewer's perspective)
        // For full moon, sun is behind the viewer
        let lightDistance: Float = 3.0
        let lightX = sin(phaseAngleRadians) * lightDistance
        let lightZ = cos(phaseAngleRadians) * lightDistance
        
        // Create directional light to simulate sun
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 2000
        directionalLight.light.color = .white
        directionalLight.position = [lightX, 0, lightZ]
        
        // Make light look at the moon
        directionalLight.look(at: moonEntity.position, from: directionalLight.position, relativeTo: nil)
        lightAnchor.addChild(directionalLight)
        
        // Add subtle ambient light for visibility of dark side
        let ambientLight = PointLight()
        ambientLight.light.intensity = 100
        ambientLight.light.color = .init(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        ambientLight.light.attenuationRadius = 10
        ambientLight.position = [0, 0, 2]
        lightAnchor.addChild(ambientLight)
    }
    
    // Convert illumination fraction (0-1) to phase angle in degrees
    private func phaseAngleDegrees(illuminationFraction k: Double) -> Double {
        // Clamp k to [0, 1] to avoid domain errors in acos
        let kClamped = min(max(k, 0.0), 1.0)
        
        // k = (1 + cos α) / 2  =>  cos α = 2k - 1
        let cosAlpha = 2.0 * kClamped - 1.0
        
        // acos returns radians
        let alphaRad = acos(cosAlpha)
        
        // Convert to degrees
        let alphaDeg = alphaRad * 180.0 / .pi
        return alphaDeg
    }
    
    // Get the illumination fraction for each moon phase (0 = new moon, 1 = full moon)
    private func getIlluminationFraction(_ phase: MoonPhase) -> Float {
        switch phase {
        case .new:
            return 0.0  // 0% illuminated
        case .waxingCrescent:
            return 0.25  // 25% illuminated
        case .firstQuarter:
            return 0.5  // 50% illuminated
        case .waxingGibbous:
            return 0.75  // 75% illuminated
        case .full:
            return 1.0  // 100% illuminated
        case .waningGibbous:
            return 0.75  // 75% illuminated
        case .lastQuarter:
            return 0.5  // 50% illuminated
        case .waningCrescent:
            return 0.25  // 25% illuminated
        @unknown default:
            return 0
        }
    }
    
    // Get the phase angle in radians for positioning the light source
    private func getMoonPhaseAngle(_ phase: MoonPhase) -> Float {
        // The angle represents where the sun is relative to the moon-earth-observer system
        // 0° = new moon (sun behind moon)
        // 180° = full moon (sun behind observer)
        switch phase {
        case .new:
            return 0  // Sun behind moon
        case .waxingCrescent:
            return .pi / 4  // 45°
        case .firstQuarter:
            return .pi / 2  // 90° - Sun to the right
        case .waxingGibbous:
            return 3 * .pi / 4  // 135°
        case .full:
            return .pi  // 180° - Sun behind viewer
        case .waningGibbous:
            return 5 * .pi / 4  // 225°
        case .lastQuarter:
            return 3 * .pi / 2  // 270° - Sun to the left
        case .waningCrescent:
            return 7 * .pi / 4  // 315°
        @unknown default:
            return 0
        }
    }
    
    class Coordinator {
        var moonEntity: ModelEntity?
        var arView: ARView?
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
