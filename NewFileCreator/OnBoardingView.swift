//
//  OnBoardingView.swift
//  NewFileCreator
//
//  Created by Peter on 26.03.26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @AppStorage("hasReviewedFullDiskAccess") private var hasReviewedFullDiskAccess = false

    @State private var currentStep = 0
    @State private var isExtensionEnabled = ExtensionChecker.isFinderExtensionEnabled()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color.accentColor.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    WelcomeStep()
                        .tag(0)
                    FullDiskAccessStep(hasReviewedFullDiskAccess: $hasReviewedFullDiskAccess)
                        .tag(1)
                    EnableExtensionStep(
                        isExtensionEnabled: $isExtensionEnabled,
                        canFinishOnboarding: canFinishOnboarding,
                        onFinish: finishOnboarding
                    )
                    .tag(2)
                }
                .tabViewStyle(.automatic)
                .animation(.easeInOut(duration: 0.22), value: currentStep)

                BottomBar(
                    currentStep: $currentStep,
                    totalSteps: 3,
                    canAdvanceFromCurrentStep: canAdvanceFromCurrentStep,
                    finishHelpText: finishHelpText,
                    onFinish: finishOnboarding
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.2))
                    )
            )
            .padding(20)
        }
        .frame(width: 620, height: 500)
        .onAppear {
            refreshChecks()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshChecks()
            }
        }
    }

    private var canAdvanceFromCurrentStep: Bool {
        switch currentStep {
        case 1:
            return hasReviewedFullDiskAccess
        case 2:
            return canFinishOnboarding
        default:
            return true
        }
    }

    private var canFinishOnboarding: Bool {
        hasReviewedFullDiskAccess && isExtensionEnabled
    }

    private var finishHelpText: String? {
        switch currentStep {
        case 1 where !hasReviewedFullDiskAccess:
            return "Confirm the Full Disk Access step before you continue."
        case 2 where !hasReviewedFullDiskAccess:
            return "Complete the Full Disk Access step first."
        case 2 where !isExtensionEnabled:
            return "The Finder extension must be enabled before setup can finish."
        default:
            return nil
        }
    }

    private func refreshChecks() {
        isExtensionEnabled = ExtensionChecker.isFinderExtensionEnabled()
    }

    private func finishOnboarding() {
        onboardingCompleted = true
    }
}
