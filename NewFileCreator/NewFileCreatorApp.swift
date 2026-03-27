//
//  NewFileCreatorApp.swift
//  NewFileCreator
//
//  Created by Peter on 26.03.26.
//

import SwiftUI

@main
struct NewFileCreatorApp: App {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    var body: some Scene {
        WindowGroup {
            if onboardingCompleted {
                CompletedView()
            } else {
                OnboardingView()
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
