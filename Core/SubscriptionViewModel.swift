//
//  SubscriptionViewModel.swift
//  BlurFace
//
//  Created by Arek on 12/06/2025.
//

import Foundation
import RevenueCat

@Observable final class SubscriptionViewModel {
    
    private let storeManager: StoreManager
    
    var isLoading = false
    var isProSubscriber = false
    var shouldShowPaywall = false
    
    init(storeManager: StoreManager = RevenueCatStoreManager()) {
        self.storeManager = storeManager
    }
    
    @MainActor
    func checkSubscriptionStatus() async {
        isLoading = true
        
        do {
            isProSubscriber = try await storeManager.isProEnabled()
            shouldShowPaywall = !isProSubscriber
        } catch {
            print("Error checking subscription status: \(error)")
            shouldShowPaywall = false
        }
        
        isLoading = false
    }
    
    @MainActor
    func handleOnboardingDismissed() async {
        await checkSubscriptionStatus()
    }
}
