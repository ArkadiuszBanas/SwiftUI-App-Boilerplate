//
//  StoreManager.swift
//  Blur Face
//
//  Created by Arek on 12/06/2025.
//


import Foundation
import RevenueCat

// MARK: - Paywall Source Tracking
enum PaywallSource: String, CaseIterable {
    case afterOnboarding = "after_onboarding"
    case exportAttempt = "export_attempt"
    
    var attributeKey: String {
        return "paywall_source"
    }
}

protocol StoreManager {

    func isProEnabled() async throws -> Bool
    func setPaywallSource(_ source: PaywallSource)
}

enum RevenueCatStoreManagerError: Error {

    case noOfferingFound
    case loadingOfferingsFailed
}

final class RevenueCatStoreManager: StoreManager {

    private enum Constant {

        static let proEntitlementKey = "pro"
        static let currentOffering = "weekly.yearly"
    }

    func isProEnabled() async throws -> Bool {

        let customerInfo = try await Purchases.shared.customerInfo()
        let activeEntitlements = customerInfo.entitlements.active
        return activeEntitlements[Constant.proEntitlementKey]?.isActive ?? false
    }
    
    func setPaywallSource(_ source: PaywallSource) {
        Purchases.shared.attribution.setAttributes([
            source.attributeKey: source.rawValue
        ])
        print("🎯 PaywallSource set to: \(source.rawValue)")
    }
}
