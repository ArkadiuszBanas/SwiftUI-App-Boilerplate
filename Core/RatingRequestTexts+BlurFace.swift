//
//  RatingRequestTexts+BlurFace.swift
//  Blur Face
//
//  Created by Arek on 22/06/2025.
//

import Foundation

extension RatingRequestTexts {

    static var `default`: RatingRequestTexts {
        RatingRequestTexts(
            title: NSLocalizedString("rating_satisfaction_title", comment: "Czy jesteś zadowolony z aplikacji?"),
            message: NSLocalizedString("rating_satisfaction_message", comment: "Pomóż nam ulepszyć aplikację!"),
            yesButton: NSLocalizedString("rating_satisfaction_yes", comment: "Tak"),
            noButton: NSLocalizedString("rating_satisfaction_no", comment: "Nie")
        )
    }
}
