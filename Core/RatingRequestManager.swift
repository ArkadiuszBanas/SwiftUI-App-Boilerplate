import SwiftUI
import StoreKit

// MARK: - Rating Request Texts
struct RatingRequestTexts {

    let title: String
    let message: String
    let yesButton: String
    let noButton: String    
}

@Observable final class RatingRequestManager {
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let exportCount = "exportCount"
        static let lastRatingRequestExportCount = "lastRatingRequestExportCount"
        static let hasBeenAskedForRating = "hasBeenAskedForRating"
        static let hasRatedApp = "hasRatedApp"
    }
    
    // MARK: - Properties
    private let exportCountInterval: Int = 3
    private let texts: RatingRequestTexts
    
    // MARK: - Initialization
    init(texts: RatingRequestTexts = .default) {
        self.texts = texts
    }
    
    // MARK: - Public Methods
    
    /// Wywoływana po każdym eksporcie zdjęcia
    func recordExport() {
        incrementExportCount()
        
        let currentCount = getExportCount()
        let hasRatedApp = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasRatedApp)
        let hasBeenAsked = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasBeenAskedForRating)
        let lastRequestCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.lastRatingRequestExportCount)
        
        print("🔍 Debug RatingRequestManager:")
        print("   Export count: \(currentCount)")
        print("   Has rated app: \(hasRatedApp)")
        print("   Has been asked: \(hasBeenAsked)")
        print("   Last request count: \(lastRequestCount)")
        print("   Should show request: \(shouldShowRatingRequest())")
        
        if shouldShowRatingRequest() {
            print("   ✅ Showing satisfaction alert")
            showSatisfactionAlert()
        } else {
            print("   ❌ NOT showing satisfaction alert")
        }
    }
    
    // MARK: - Private Methods
    
    /// Zwiększa licznik eksportów
    private func incrementExportCount() {
        let currentCount = getExportCount()
        UserDefaults.standard.set(currentCount + 1, forKey: UserDefaultsKeys.exportCount)
        UserDefaults.standard.synchronize()
    }
    
    /// Pobiera aktualną liczbę eksportów
    private func getExportCount() -> Int {
        UserDefaults.standard.integer(forKey: UserDefaultsKeys.exportCount)
    }
    
    /// Sprawdza czy należy wyświetlić prośbę o ocenę
    private func shouldShowRatingRequest() -> Bool {
        // Jeśli użytkownik już ocenił aplikację, nigdy nie pokazuj prośby
        let hasRatedApp = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasRatedApp)
        if hasRatedApp {
            return false
        }
        
        let currentCount = getExportCount()
        let lastRequestCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.lastRatingRequestExportCount)
        let hasBeenAsked = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasBeenAskedForRating)
        
        // Pierwsza prośba przy pierwszym eksporcie
        if currentCount == 1 && !hasBeenAsked {
            return true
        }
        
        // Kolejne prośby co 3 eksporty
        if currentCount - lastRequestCount >= exportCountInterval {
            return true
        }
        
        return false
    }
    
    /// Wyświetla alert z pytaniem o satysfakcję
    private func showSatisfactionAlert() {
        let alert = UIAlertController(
            title: texts.title,
            message: texts.message,
            preferredStyle: .alert
        )
        
        // Opcja "Tak" - prowadzi do oceny w App Store
        let yesAction = UIAlertAction(
            title: texts.yesButton,
            style: .default
        ) { [weak self] _ in
            self?.requestAppStoreRating()
        }
        
        // Opcja "Nie" - zamyka alert
        let noAction = UIAlertAction(
            title: texts.noButton,
            style: .cancel
        ) { [weak self] _ in
            self?.recordRatingRequestShown()
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        // Ustawienie "Tak" jako preferowanej akcji (pogrubiony)
        alert.preferredAction = yesAction
        
        // Wyświetl alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
        
        recordRatingRequestShown()
    }
    
    /// Wywołuje natywny popup oceny App Store
    private func requestAppStoreRating() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            
            // Zaznacz że użytkownik był już poproszony o ocenę przez natywny popup
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasRatedApp)
            UserDefaults.standard.synchronize() // Krytyczny zapis - wymuszamy synchronizację
        }
    }
    
    /// Zapisuje że prośba o ocenę została wyświetlona
    private func recordRatingRequestShown() {
        let currentCount = getExportCount()
        UserDefaults.standard.set(currentCount, forKey: UserDefaultsKeys.lastRatingRequestExportCount)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasBeenAskedForRating)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Testing Support
extension RatingRequestManager {
    /// Resetuje wszystkie dane - do celów testowych
    func resetData() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.exportCount)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lastRatingRequestExportCount)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.hasBeenAskedForRating)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.hasRatedApp)
        UserDefaults.standard.synchronize()
    }
    
    /// Pobiera aktualną liczbę eksportów - do celów testowych
    func getCurrentExportCount() -> Int {
        getExportCount()
    }
    
    /// Wymusza reset danych i pokazanie alertu przy następnym eksporcie - do testowania
    func forceShowRatingRequest() {
        print("🔄 Forcing rating request reset")
        resetData()
        print("🔄 All UserDefaults cleared - next export will show rating request")
    }
} 
