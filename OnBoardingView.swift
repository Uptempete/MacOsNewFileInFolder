//
//  OnboardingView.swift
//  NewFileCreator
//
//  Created by Peter on 26.03.26.
//

import SwiftUI
internal import Combine

// MARK: - Main Onboarding View

/// The three-step onboarding flow shown on first launch.
struct OnboardingView: View {

    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @State private var currentStep = 0

    var body: some View {
        ZStack {
            // Background
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Step content
                TabView(selection: $currentStep) {
                    WelcomeStep()
                        .tag(0)
                    FullDiskAccessStep()
                        .tag(1)
                    EnableExtensionStep()
                        .tag(2)
                }
                .tabViewStyle(.automatic)
                .animation(.easeInOut, value: currentStep)

                // Progress dots + navigation
                BottomBar(
                    currentStep: $currentStep,
                    totalSteps: 3,
                    onFinish: { onboardingCompleted = true }
                )
            }
        }
        .frame(width: 520, height: 420)
    }
}

// MARK: - Step 1: Welcome

private struct WelcomeStep: View {
    var body: some View {
        StepLayout(
            icon: "doc.badge.plus",
            iconColor: .blue,
            title: "Welcome to NewFileCreator",
            description: "Right-click anywhere in Finder to instantly create new files — text, markdown, Swift, Python, and more.\n\nLet's get you set up in two quick steps."
        )
    }
}

// MARK: - Step 2: Full Disk Access

private struct FullDiskAccessStep: View {

    @State private var accessGranted = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        StepLayout(
            icon: accessGranted ? "checkmark.shield.fill" : "shield.fill",
            iconColor: accessGranted ? .green : .orange,
            title: "Grant Full Disk Access",
            description: "NewFileCreator needs Full Disk Access to create files in any folder on your Mac.\n\nClick the button below to open System Settings, then enable NewFileCreator."
        ) {
            if accessGranted {
                Label("Access granted", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.callout.weight(.medium))
            } else {
                Button {
                    NSWorkspace.shared.open(
                        URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
                    )
                } label: {
                    Label("Open System Settings", systemImage: "gear")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onReceive(timer) { _ in
            checkAccess()
        }
        .onAppear {
            checkAccess()
        }
    }

    /// Checks whether Full Disk Access has been granted by attempting
    /// to read a protected directory.
    private func checkAccess() {
        accessGranted = FileManager.default.isReadableFile(
            atPath: "/Library/Application Support"
        )
    }
}

// MARK: - Step 3: Enable Extension

private struct EnableExtensionStep: View {

    var body: some View {
        StepLayout(
            icon: "puzzlepiece.extension.fill",
            iconColor: .purple,
            title: "Enable the Finder Extension",
            description: "Almost there! Open System Settings and enable NewFileCreator under Extensions → Added Extensions.\n\nAfter that, right-click in Finder to try it out."
        ) {
            Button {
                NSWorkspace.shared.open(
                    URL(string: "x-apple.systempreferences:com.apple.preference.extensions?Finder")!
                )
            } label: {
                Label("Open Extensions Settings", systemImage: "puzzlepiece")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Completed View

/// Shown after onboarding is finished. Allows re-opening settings if needed.
struct CompletedView: View {

    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("You're all set!")
                .font(.title.bold())

            Text("Right-click any folder or file in Finder\nto create a new file.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Divider()

            HStack(spacing: 12) {
                Button("Reset Onboarding") {
                    onboardingCompleted = false
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.callout)

                Button {
                    NSWorkspace.shared.open(
                        URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
                    )
                } label: {
                    Label("System Settings", systemImage: "gear")
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(width: 520, height: 420)
        .padding(40)
    }
}

// MARK: - Reusable Components

/// Generic step layout with icon, title, description, and optional action content.
private struct StepLayout<Actions: View>: View {

    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    var actions: (() -> Actions)?

    init(
        icon: String,
        iconColor: Color,
        title: String,
        description: String,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(iconColor)
            }

            // Title
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            // Description
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 360)

            // Optional action button
            if let actions {
                actions()
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// Convenience init without actions
extension StepLayout where Actions == EmptyView {
    init(icon: String, iconColor: Color, title: String, description: String) {
        self.init(icon: icon, iconColor: iconColor, title: title, description: description) {
            EmptyView()
        }
    }
}

/// Bottom navigation bar with progress dots and next/finish button.
private struct BottomBar: View {

    @Binding var currentStep: Int
    let totalSteps: Int
    let onFinish: () -> Void

    var body: some View {
        HStack {
            // Back button
            Button("Back") {
                withAnimation { currentStep -= 1 }
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            .opacity(currentStep > 0 ? 1 : 0)
            .disabled(currentStep == 0)

            Spacer()

            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: index == currentStep ? 8 : 6,
                               height: index == currentStep ? 8 : 6)
                        .animation(.spring(), value: currentStep)
                }
            }

            Spacer()

            // Next / Finish button
            Button(currentStep == totalSteps - 1 ? "Finish" : "Next") {
                withAnimation {
                    if currentStep == totalSteps - 1 {
                        onFinish()
                    } else {
                        currentStep += 1
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(.bar)
    }
}
