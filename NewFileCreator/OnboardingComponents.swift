//
//  OnboardingComponents.swift
//  NewFileCreator
//
//  Created by Peter on 26.03.26.
//

import SwiftUI

struct StepLayout<Actions: View>: View {
    let stepNumber: Int
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let actions: Actions

    init(
        stepNumber: Int,
        icon: String,
        iconColor: Color,
        title: String,
        description: String,
        @ViewBuilder actions: () -> Actions
    ) {
        self.stepNumber = stepNumber
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.actions = actions()
    }

    var body: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 20)

            Text("Step \(stepNumber) of 3")
                .font(.headline)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Step \(stepNumber) of 3")

            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.14))
                    .frame(width: 96, height: 96)

                Circle()
                    .stroke(iconColor.opacity(0.35), lineWidth: 1)
                    .frame(width: 96, height: 96)

                Image(systemName: icon)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 460)
            }

            actions
                .frame(maxWidth: 500)

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 40)
        .padding(.top, 10)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
    }
}

struct InstructionPanel: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1).")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)
                    Text(items[index])
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
        .accessibilityElement(children: .contain)
    }
}

struct StatusNote: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.secondary)
            Text(text)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.callout)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct QuickActionCard: View {
    let title: String
    let detail: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.accentColor)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(detail)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                Label("Open", systemImage: "arrow.up.right.square")
                    .font(.callout.weight(.semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.56))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(detail)
    }
}

struct BottomBar: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    let canAdvanceFromCurrentStep: Bool
    let finishHelpText: String?
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button("Back") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .opacity(currentStep > 0 ? 1 : 0)
                .disabled(currentStep == 0)

                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? Color.accentColor : Color.secondary.opacity(0.22))
                            .frame(width: index == currentStep ? 28 : 10, height: 10)
                            .animation(.spring(response: 0.28, dampingFraction: 0.8), value: currentStep)
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("Progress")
                .accessibilityValue("Step \(currentStep + 1) of \(totalSteps)")

                Spacer()

                Button(currentStep == totalSteps - 1 ? "Finish onboarding" : "Next") {
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
                .disabled(!canAdvanceFromCurrentStep)
            }

            if let finishHelpText {
                Text(finishHelpText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
        .background(.bar)
    }
}
