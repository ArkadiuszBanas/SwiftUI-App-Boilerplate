//
//  BlurFaceOnboarding.swift
//  BlurFace
//
//  Created by Arek on 12/06/2025.
//

import SwiftUI
import OnBoardingKit

struct BlurFaceOnboarding: OnBoarding {
    var title: Text {
        Text("Welcome to FaceBlur")
    }

    var description: Text? {
        Text("Blur faces, sensitive info, and unwanted details with just one tap.")
    }

    var features: [Feature] {
        [
            Feature(
                image: Image(systemName: "drop.halffull"),
                label: Text("Custom blur areas"),
                description: Text("Add and resize blur masks anywhere")
            ),
            Feature(
                image: Image(systemName: "hand.point.up.left"),
                label: Text("Professional results"),
                description: Text("Smooth edges with advanced feathering")
            ),
            Feature(
                image: Image(systemName: "bolt"),
                label: Text("Lightning fast"),
                description: Text("Metal GPU acceleration for instant processing")
            ),
            Feature(
                image: Image(systemName: "lock"),
                label: Text("Complete privacy"),
                description: Text("All editing happens offline on your device")
            ),
        ]
    }

    var button: Text {
        Text("Let's go!")
    }
}

#Preview {
    OnBoardingView(BlurFaceOnboarding(), action: {})
}
