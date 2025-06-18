//
//  OnboardingView.swift
//  Blur Face
//
//  Created by Arek on 14/06/2025.
//

import SwiftUI
import SharedFoundation
import SharedSwiftUI

struct Step: Equatable {

    let title: String
    let image: UIImage
    var showToolbar = false
}

extension Step {

    static func makeSteps() -> [Step] {
        [
            .init(
                title: NSLocalizedString("onboarding.step1_title", comment: ""),
                image: UIImage(named: "onboarding-1")!
            ),
            .init(
                title: NSLocalizedString("onboarding.step2_title", comment: ""),
                image: UIImage(named: "onboarding-1")!,
                showToolbar: true
            ),
            .init(
                title: NSLocalizedString("onboarding.step3_title", comment: ""),
                image: UIImage(named: "onboarding-1")!
            ),
            .init(
                title: NSLocalizedString("onboarding.step4_title", comment: ""),
                image: UIImage(named: "onboarding-2")!
            )
        ]
    }
}

struct OnboardingView: View {

    @State var currentStep: Step = Step.makeSteps()[0]
    @State private var steps: [Step] = Step.makeSteps()

    let onEnd: VoidClosure

    var body: some View {
        ZStack {
            backgroundImage
            buttonContainer
            textContainer
            bottomToolbar
                .opacity(currentStep.showToolbar ? 1 : 0)
        }
        .animation(.default, value: currentStep)
        .onLoad {
            steps.removeFirst()
        }
    }

    var backgroundImage: some View {
        Image(uiImage: currentStep.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .animation(.default, value: currentStep)
            .frame(
                maxWidth: UIScreen.main.bounds.width,
                maxHeight: UIScreen.main.bounds.height
            )
            .clipped()
            .ignoresSafeArea()
    }

    var buttonContainer: some View {
        Button {
            goToNextStep()
        } label: {
            Circle()
                .fill(Color.blue)
                .frame(width: 60, height: 60)
                .shadow(radius: 4)
                .overlay {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 24))
                        .sfSymbolAnimation()
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.bottom, 8)
        .padding(.horizontal, 24)
    }

    var textContainer: some View {
        VStack {
            Text(currentStep.title)
                .animation(.default, value: currentStep)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .font(.system(size: 32, weight: .medium, design: .default))
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .animation(.default, value: currentStep)
                        .foregroundStyle(Color.blue.opacity(0.75))
                        .shadow(radius: 4)
                }
            Spacer()
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .foregroundStyle(.white)
    }

    var bottomToolbar: some View {
        BottomToolbar(
            selectedPhoto: .constant(nil),
            selectedImage: UIImage(named: "test"),
            isExporting: false,
            onAddShape: {},
            onExport: {}
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 90)
        .allowsHitTesting(false)
    }

    private func goToNextStep() {
        if steps.isEmpty {
            onEnd()
        } else {
            currentStep = steps[0]
            steps.removeFirst()
        }
    }
}

#Preview {
    OnboardingView(onEnd: {})
}
