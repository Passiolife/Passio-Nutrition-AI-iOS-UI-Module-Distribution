//
//  OverlayManager.swift
//
//
//  Created by Davido Hyer on 7/10/24.
//

import UIKit

final class TokenUsageOverlayManager {

    static let shared = TokenUsageOverlayManager()

    private var lastBudget = PassioTokenBudget()
    private var overlayWindow: UIWindow?
    private var textLabel: UILabel?
    private var progressBar: UIProgressView?
    private var parentView: UIView?
    private let padding: CGFloat = 2
    private var isVisible = false
    private(set) var totalSessionTokens = 0

    private init() {
        setupLayout()
        totalSessionTokens = 0
    }

    private func setupLayout() {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            else { return }

            let overlayWindow = UIWindow(windowScene: windowScene)
            overlayWindow.frame = UIScreen.main.bounds
            overlayWindow.windowLevel = .alert + 1
            overlayWindow.isUserInteractionEnabled = false

            let parentView = UIView()
            parentView.backgroundColor = UIColor(white: 0.3, alpha: 1)
            parentView.layer.cornerRadius = 5
            parentView.layer.maskedCorners = [.layerMinXMinYCorner]
            parentView.clipsToBounds = true
            parentView.translatesAutoresizingMaskIntoConstraints = false
            parentView.widthAnchor.constraint(equalToConstant: 130).isActive = true

            let progressBar = UIProgressView(progressViewStyle: .default)
            progressBar.progress = 0
            progressBar.tintColor = .systemIndigo
            progressBar.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            progressBar.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = ""
            label.textColor = .white
            label.backgroundColor = UIColor.clear
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 8, weight: .bold)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false

            let spacer = UIView()
            spacer.backgroundColor = .clear
            spacer.widthAnchor.constraint(equalToConstant: 50).isActive = true

            let horizontalStackView = UIStackView(arrangedSubviews: [progressBar, spacer])
            horizontalStackView.axis = .horizontal
            horizontalStackView.alignment = .fill
            horizontalStackView.spacing = 0
            horizontalStackView.translatesAutoresizingMaskIntoConstraints = false

            let stackView = UIStackView(arrangedSubviews: [label, horizontalStackView])
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 0.5
            stackView.translatesAutoresizingMaskIntoConstraints = false

            parentView.addSubview(stackView)

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: padding),
                stackView.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: padding),
                stackView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -padding),
                stackView.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: -padding)
            ])

            overlayWindow.addSubview(parentView)

            NSLayoutConstraint.activate([
                parentView.bottomAnchor.constraint(equalTo: overlayWindow.bottomAnchor, constant: 0),
                parentView.trailingAnchor.constraint(equalTo: overlayWindow.trailingAnchor, constant: 12)
            ])

            overlayWindow.isHidden = true
            self.overlayWindow = overlayWindow
            self.parentView = parentView
            self.textLabel = label
            self.progressBar = progressBar
        }
    }

    private func updateVisibility() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            overlayWindow?.isHidden = lastBudget.budgetCap <= 0 ? true : !isVisible
        }
    }

    func updateOverlay(withBudget budget: PassioTokenBudget) {

        totalSessionTokens += budget.requestUsage
        lastBudget = budget
        let totalSessionsUsage = "Session: \(totalSessionTokens)"
        let lastRequestUsage = "Last Request: \(budget.requestUsage)"

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            textLabel?.text = "\(totalSessionsUsage)\n\(lastRequestUsage)"
            progressBar?.progress = budget.usedPercent
            updateVisibility()
        }
    }

    func showOverlay() {
        isVisible = true
        updateVisibility()
    }

    func hideOverlay() {
        isVisible = false
        updateVisibility()
    }
}
