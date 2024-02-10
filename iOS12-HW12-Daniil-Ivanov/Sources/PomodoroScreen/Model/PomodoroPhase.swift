//
//  PomodoroPhase.swift
//  iOS12-HW12-Daniil-Ivanov
//
//  Created by Daniil (work) on 10.02.2024.
//

import Foundation
import UIKit

enum PomodoroPhase {
    case work
    case rest

    var initialTime: TimeInterval {
        switch self {
        case .work: Constants.workTime
        case .rest: Constants.restTime
        }
    }
}

extension PomodoroPhase {
    var color: UIColor {
        switch self {
        case .work: StyleConstants.progressBarWorkStrokeColor
        case .rest: StyleConstants.progressBarRestStrokeColor
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .work: StyleConstants.progressBarWorkBackgroundStrokeColor
        case .rest: StyleConstants.progressBarRestBackgroundStrokeColor
        }
    }
}

// MARK: - Constants

fileprivate enum StyleConstants {
    static let progressBarWorkBackgroundStrokeColor = UIColor(red: 250 / 255, green: 222 / 255, blue: 219 / 255, alpha: 1)
    static let progressBarWorkStrokeColor = UIColor(red: 252 / 255, green: 140 / 255, blue: 128 / 255, alpha: 1)
    static let progressBarRestBackgroundStrokeColor = UIColor(red: 176 / 255, green: 227 / 255, blue: 208 / 255, alpha: 1)
    static let progressBarRestStrokeColor = UIColor(red: 97 / 255, green: 197 / 255, blue: 163 / 255, alpha: 1)
}

fileprivate enum Constants {
    // Время работы в секундах.
    static let workTime = TimeInterval(5)

    // Время отдыха в секундах.
    static let restTime = TimeInterval(3)
}
