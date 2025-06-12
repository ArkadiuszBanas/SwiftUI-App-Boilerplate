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
import OnBoardingKit

@main
struct BlurFaceApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var subscriptionViewModel = SubscriptionViewModel()

    // TODO: REFACTOR getting this information. It's hardcoded in OnBoardingKit
    @AppStorage("hasOnBoardingBeenPresented") private var hasOnboardingBeenPresented: Bool = false

    var body: some Scene {

        let shouldShowPaywallBinding = Binding<Bool>(
            get: { subscriptionViewModel.shouldShowPaywall && hasOnboardingBeenPresented },
            set: { subscriptionViewModel.shouldShowPaywall = $0 }
        )

        WindowGroup {
            AppCoordinator()
                .presentOnBoarding(
                    BlurFaceOnboarding()
                )
                .sheet(isPresented: shouldShowPaywallBinding) {
                    PaywallView()
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
