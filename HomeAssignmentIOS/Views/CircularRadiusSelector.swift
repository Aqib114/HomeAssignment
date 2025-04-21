//
//  CircularRadiusSelector.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 21/04/2025.
//

import SwiftUI

struct CircularRadiusSelector: View {
    @Binding var radius: Double
    var maxRadius: Double = 1000

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 30)

            Circle()
                .trim(from: 0, to: CGFloat(radius / maxRadius))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(radius)) m")
                .font(.title)
                .bold()
        }
        .frame(width: 200, height: 200)
        .gesture(DragGesture(minimumDistance: 0).onChanged { value in
            updateRadius(with: value)
        })
    }

    private func updateRadius(with value: DragGesture.Value) {
        let center = CGPoint(x: 100, y: 100)
        let dx = value.location.x - center.x
        let dy = value.location.y - center.y
        var angle = atan2(dy, dx) + .pi / 2
        if angle < 0 {
            angle += 2 * .pi
        }
        let percent = angle / (2 * .pi)
        radius = percent * maxRadius
    }
}
