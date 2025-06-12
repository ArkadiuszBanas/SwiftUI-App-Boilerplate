//
//  BlurFaceApp.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI
import RevenueCat
import OnBoardingKit

@main
struct BlurFaceApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppCoordinator()
                .presentOnBoarding(BlurFaceOnboarding())
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
