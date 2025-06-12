//
//  StoreManager.swift
//  Blur Face
//
//  Created by Arek on 12/06/2025.
//


import Foundation
import RevenueCat

protocol StoreManager {

    func isProEnabled() async throws -> Bool
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
}
