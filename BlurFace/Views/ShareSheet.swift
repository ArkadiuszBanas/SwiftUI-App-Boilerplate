//
//  ShareSheet.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var onCompletion: ((UIActivity.ActivityType?, Bool) -> Void)? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Configure completion handler
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            onCompletion?(activityType, completed)
        }
        
        // Exclude activities that might cause memory issues on older devices
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .print,
            .openInIBooks
        ]
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
} 