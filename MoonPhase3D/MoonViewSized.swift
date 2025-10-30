//
//  MoonViewSized.swift
//  MoonPhase3D
//
//  Created by Xcode Developer on 10/30/25.
//

import Foundation
import SwiftUI
import WeatherKit

struct MoonViewSized: View {
    let moonPhase: MoonPhase
    var horizontalPadding: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            MoonView(moonPhase: moonPhase)
                .frame(
                    width: geo.size.width - (horizontalPadding * 2),
                    height: geo.size.width - (horizontalPadding * 2)
                )
                .padding(.horizontal, horizontalPadding)
        }
        .frame(height: .infinity) // keep a square
    }
}
