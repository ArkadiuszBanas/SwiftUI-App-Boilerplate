//
//  AppCoordinator.swift
//  BlurFace
//
//  Created by Arek on 21/10/2023.
//

import SwiftUI
import FlowStacks

struct AppCoordinator: View {

    let storeManager: StoreManager

    enum Screen {

        case home
    }

    @State var routes: Routes<Screen> = [.root(.home)]

    var body: some View {
        Router($routes) { screen, _ in
            switch screen {
            case .home:
                EditorView()
            }
        }
    }
}
