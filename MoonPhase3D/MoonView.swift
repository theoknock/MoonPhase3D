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
        
        // Add rotation animation
//        addRotationAnimation(to: moonEntity)
        
        // Store the moon entity in the context for updates
        context.coordinator.moonEntity = moonEntity
        context.coordinator.arView = arView
        
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
        // Create sphere mesh
        let moonMesh = MeshResource.generateSphere(radius: 1.0)
        
        // Create material with moon texture
        var moonMaterial = SimpleMaterial()
        
        // Load moon texture
        // Note: You'll need to add a moon texture image to your project
        // You can download a high-resolution moon map from NASA or other sources
        if let moonTexture = try? TextureResource.load(named: "moon-diffuse") {
            moonMaterial.color = .init(tint: .white, texture: .init(moonTexture))
        } else {
            // Fallback to a gray color if texture is not found
            moonMaterial.color = .init(tint: .lightGray)
        }
        
        moonMaterial.metallic = 0.0
        moonMaterial.roughness = 1.0
        
        // Create the moon entity
        let moonEntity = ModelEntity(mesh: moonMesh, materials: [moonMaterial])
        
        // Position the moon
        moonEntity.position = [0, 0, -0.5]
        
        return moonEntity
    }
    
    private func setupCamera(arView: ARView) {
        // Disable default camera controls
        arView.cameraMode = .nonAR
        
        // Create a perspective camera
//        let cameraEntity = PerspectiveCameraComponent()
        
        // Set up the camera anchor
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.position = [0, 0, 0.5]
        
        arView.scene.addAnchor(cameraAnchor)
    }
    

    
//    private func addRotationAnimation(to entity: ModelEntity) {
//        // Create a slow rotation animation
//        let rotationAnimation = entity.move(
//            to: Transform(
//                scale: entity.scale,
//                rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0]),
//                translation: entity.position
//            ),
//            relativeTo: entity.parent,
//            duration: 30,
//            timingFunction: .linear
//        )
//        
//
//        // ERROR: - This method is deprecated and will be removed in future versions
//        // Make it repeat
////        if rotationAnimation != nil {
////            entity.playAnimation(rotationAnimation!.repeat())
////        }
//    }
    
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
        
        // Calculate light position based on moon phase
        let phaseAngle = getMoonPhaseAngle(moonPhase)
        
        // Create directional light to simulate sun
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 50000
        directionalLight.light.color = .white
        directionalLight.light.isRealWorldProxy = false
        
        // Position light based on moon phase
        let lightX = sin(phaseAngle) * 2
        let lightZ = cos(phaseAngle) * 2
        directionalLight.position = [lightX, 0, lightZ]
        
        // Make light look at the moon
        directionalLight.look(at: moonEntity.position, from: directionalLight.position, relativeTo: nil)
        
        lightAnchor.addChild(directionalLight)
        
        // Add ambient light for visibility
        let ambientLight = PointLight()
        ambientLight.light.intensity = 500
        ambientLight.light.color = .init(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        ambientLight.position = [0, 0, 1]
        lightAnchor.addChild(ambientLight)
    }
    
    private func getMoonPhaseAngle(_ phase: MoonPhase) -> Float {
        switch phase {
        case .new:
            return 0 // Sun behind moon
        case .waxingCrescent:
            return .pi / 4
        case .firstQuarter:
            return .pi / 2 // Sun to the right
        case .waxingGibbous:
            return 3 * .pi / 4
        case .full:
            return .pi // Sun in front of moon
        case .waningGibbous:
            return 5 * .pi / 4
        case .lastQuarter:
            return 3 * .pi / 2 // Sun to the left
        case .waningCrescent:
            return 7 * .pi / 4
        @unknown default:
            return 0
        }
    }
    
    class Coordinator {
        var moonEntity: ModelEntity?
        var arView: ARView?
    }
}
