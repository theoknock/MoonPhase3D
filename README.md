# Moon Phase 3D Viewer

A SwiftUI app that displays a realistic 3D moon using RealityKit with accurate moon phase visualization based on real-time data from WeatherKit.

## Features

- **3D Moon Rendering**: Uses RealityKit to create a spherical moon model
- **Realistic Texture Mapping**: Applies high-resolution moon surface texture
- **Real-time Moon Phase**: Fetches current moon phase data using WeatherKit
- **Dynamic Lighting**: Adjusts lighting to accurately represent the current moon phase
- **Smooth Animation**: Includes rotation animation for better visualization
- **Information Display**: Shows current moon phase name and illumination percentage

## Setup Instructions

### 1. Project Configuration

1. Create a new iOS app in Xcode
2. Add the provided Swift files to your project
3. Enable required capabilities in your project settings

### 2. Required Frameworks

Add these frameworks to your project:
- RealityKit
- WeatherKit
- CoreLocation

### 3. WeatherKit Setup

1. Enable WeatherKit capability in your app's capabilities
2. Create an App ID with WeatherKit service enabled in Apple Developer Portal
3. Generate a WeatherKit key in your developer account

### 4. Moon Texture

You need to add a high-resolution moon texture image to your project:

1. Download a moon texture map (recommended sources):
   - NASA's Scientific Visualization Studio
   - Solar System Scope textures
   - CGTrader (free moon textures)

2. Add the image to your Assets.xcassets catalog:
   - Name it "moon_texture"
   - Recommended resolution: at least 2048x1024 pixels
   - Format: PNG or JPEG

### 5. Info.plist Configuration

The app requires location permissions to fetch accurate moon phase data. The Info.plist file is already configured with the necessary keys.

## How It Works

### Moon Phase Calculation

The app uses WeatherKit's `MoonPhase` enum to determine the current phase:
- New Moon
- Waxing Crescent
- First Quarter
- Waxing Gibbous
- Full Moon
- Waning Gibbous
- Last Quarter
- Waning Crescent

### Lighting System

The lighting dynamically adjusts based on the moon phase:
- The directional light (simulating the sun) rotates around the moon
- Light position is calculated using the moon phase angle
- Ambient lighting ensures the moon remains partially visible even in shadow

### 3D Rendering

- Creates a sphere mesh using RealityKit's `MeshResource.generateSphere`
- Applies the moon texture as a material
- Implements rotation animation for realistic effect
- Uses non-AR camera mode for consistent viewing

## Customization Options

### Adjust Moon Size
Modify the radius in `MoonView.swift`:
```swift
let moonMesh = MeshResource.generateSphere(radius: 0.15) // Change radius here
```

### Change Rotation Speed
Modify the duration in `addRotationAnimation`:
```swift
duration: 30 // Change rotation duration in seconds
```

### Custom Location
Update the default location in `MoonViewModel`:
```swift
let location = CLLocation(latitude: YOUR_LAT, longitude: YOUR_LON)
```

## Troubleshooting

### Moon appears gray
- Ensure you've added the moon_texture image to Assets.xcassets
- Check the image name matches exactly: "moon_texture"

### WeatherKit not working
- Verify WeatherKit capability is enabled
- Check your Apple Developer account has WeatherKit service active
- Ensure location permissions are granted

### No moon phase data
- Check internet connection
- Verify location services are enabled
- Review WeatherKit API limits

## Performance Notes

- The app uses simplified lighting for better performance
- Texture resolution can be adjusted based on device capabilities
- Animation is optimized for smooth 60 FPS rendering

## Future Enhancements

Consider adding:
- Libration (moon wobble) animation
- Earth shine effect during new moon
- Mare and crater labels
- Zoom controls
- Phase calendar view
- Push notifications for major phase changes

## License

This is a sample educational project. Moon texture images may have their own licensing requirements depending on the source.

<img width="489" height="1000" alt="Screenshot_alpha" src="https://github.com/user-attachments/assets/5fdefa70-ab5c-4de5-85a2-720836d9c315" />

