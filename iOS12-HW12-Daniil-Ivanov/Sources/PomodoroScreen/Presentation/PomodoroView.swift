//
//  PomodoroView.swift
//  iOS12-HW12-Daniil-Ivanov
//
//  Created by Daniil (work) on 24.01.2024.
//

import UIKit

fileprivate enum StyleConstants {
    static let backgroundColor = UIColor.white
}

class PomodoroView: UIView {

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupHierarchy()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = StyleConstants.backgroundColor
    }

    private func setupHierarchy() {

    }

    private func setupLayout() {

    }

    // MARK: - UI
}
