//
//  CircularProgressView.swift
//  Assignment9ios
//
//  Created by Justin Wilson on 5/1/23.
//

import SwiftUI

// Code from: https://sarunw.com/posts/swiftui-circular-progress-bar/

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.pink.opacity(0.5),
                    lineWidth: 10
                )
            Circle()
                .trim(from: 0, to: (progress/100))
                .stroke(
                    Color.pink,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
    }
}
