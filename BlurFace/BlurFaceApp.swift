//
//  BlurFaceApp.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI
import SharedSwiftUI
import RevenueCat
import RevenueCatUI

@main
struct BlurFaceApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var subscriptionViewModel = SubscriptionViewModel()

    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true

    var body: some Scene {

        let shouldShowPaywallBinding = Binding<Bool>(
            get: { subscriptionViewModel.shouldShowPaywall && (shouldShowOnboarding == false) },
            set: { subscriptionViewModel.shouldShowPaywall = $0 }
        )

        WindowGroup {
            AppCoordinator()
                .fullScreenCover(isPresented: $shouldShowOnboarding) {
                    OnboardingView() {
                        shouldShowOnboarding = false
                    }
                }
                .sheet(isPresented: shouldShowPaywallBinding) {
                    PaywallView()
                        .onRestoreCompleted { _ in
                            Task {
                                await subscriptionViewModel.checkSubscriptionStatus()
                            }
                        }
                }
                .onFirstTask() {
                    // Check subscription status on app launch
                    // This handles the case when onboarding wasn't presented
                    await subscriptionViewModel.checkSubscriptionStatus()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_fXLxCBJIoPFRrODisNYlNEnyXcE")

        return true
    }
}
