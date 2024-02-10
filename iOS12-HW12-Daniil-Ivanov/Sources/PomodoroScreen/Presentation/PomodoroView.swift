//
//  PomodoroView.swift
//  iOS12-HW12-Daniil-Ivanov
//
//  Created by Daniil (work) on 24.01.2024.
//

import UIKit
import SnapKit

// MARK: - Enums

fileprivate enum Status {
    case paused, started

    var image: UIImage? {
        let imageSystemName: String
        switch self {
        case .paused:
            imageSystemName = "play"
        case .started:
            imageSystemName = "pause"
        }
        return UIImage(systemName: imageSystemName)
    }

    static var defaultImage: UIImage? {
        return UIImage(systemName: "play")
    }
}

fileprivate enum PomodoroPhase {
    case work
    case rest

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

    var initialTime: TimeInterval {
        switch self {
        case .work: Constants.workTime
        case .rest: Constants.restTime
        }
    }
}

// MARK: - View

final class PomodoroView: UIView {
    private var timer: Timer? = nil
    private var currentPhase = Constants.initialPhase {
        didSet {
            updateCurrentPhaseDependantViews()
        }
    }
    private var currentTime = Constants.initialPhase.initialTime {
        didSet {
            if currentTime <= 0 {
                toggleCurrentPhase()
                currentTime = currentPhase.initialTime
                restartTimer()
                progressAnimation(duration: currentTime)
            }
            updateCurrentTimeDependantViews()
        }
    }
    private var currentStatus: Status? {
        didSet {
            updateCurrentStatusDependantViews()
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupHierarchy()
        updateCurrentTimeDependantViews()
        updateCurrentPhaseDependantViews()
        updateCurrentStatusDependantViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = StyleConstants.timerLabelFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var progressBarBackgroundShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = StyleConstants.progressBarFillColor.cgColor
        layer.lineWidth = LayoutConstants.progressBarLineWidth
        return layer
    }()

    private lazy var progressBarShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = StyleConstants.progressBarFillColor.cgColor
        layer.lineWidth = LayoutConstants.progressBarLineWidth
        layer.lineCap = .round
        layer.strokeEnd = 0.0
        return layer
    }()

    private lazy var startStopButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(startStopButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Setup

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = StyleConstants.backgroundColor
    }

    private func setupHierarchy() {
        layer.addSublayer(progressBarBackgroundShapeLayer)
        layer.addSublayer(progressBarShapeLayer)
        addSubview(timerLabel)
        addSubview(startStopButton)
    }

    private func setupLayout() {
        let progressBarRadius = LayoutConstants.getProgressBarRadius(bounds: bounds)
        let bezierPath = UIBezierPath(
            arcCenter: .zero,
            radius: progressBarRadius,
            startAngle: Constants.startPoint,
            endAngle: Constants.endPoint,
            clockwise: true
        )
        progressBarBackgroundShapeLayer.path = bezierPath.cgPath
        progressBarBackgroundShapeLayer.position = center
        progressBarShapeLayer.path = bezierPath.cgPath
        progressBarShapeLayer.position = center
        timerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-progressBarRadius * LayoutConstants.timerLabelOffset)
        }
        startStopButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(progressBarRadius * LayoutConstants.startStopButtonOffset)
        }
        if let imageView = startStopButton.imageView {
            let size = LayoutConstants.startStopButtonImageSize
            imageView.snp.makeConstraints { make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            }
            imageView.constraints.forEach { $0.priority = UILayoutPriority.defaultHigh }
        }
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }

    // MARK: - Actions

    @objc func startStopButtonTapped(sender: UIButton) {
        if currentStatus == nil {
            startTimer()
            progressAnimation(duration: currentTime)
        } else if currentStatus == .paused {
            startTimer()
            resumeAnimation()
        } else if currentStatus == .started {
            stopTimer()
            pauseAnimation()
        }
        currentStatus = currentStatus == .started ? .paused : .started
    }

    // MARK: - UI update

    private func updateCurrentTimeDependantViews() {
        updateTimerLabel()
        updateProgressBar()
    }

    private func updateCurrentPhaseDependantViews() {
        updateTimerLabel()
        updateProgressBarBackground()
        updateProgressBar()
        updateStartStopButton()
    }

    private func updateCurrentStatusDependantViews() {
        updateStartStopButton()
    }

    private func updateTimerLabel() {
        timerLabel.text = currentTime.time
        timerLabel.textColor = currentPhase.color
    }

    private func updateProgressBarBackground() {
        progressBarBackgroundShapeLayer.strokeColor = currentPhase.backgroundColor.cgColor
    }

    private func updateProgressBar() {
        progressBarShapeLayer.strokeColor = currentPhase.color.cgColor
    }

    private func updateStartStopButton() {
        startStopButton.tintColor = currentPhase.color
        guard let image = currentStatus?.image ?? Status.defaultImage else { return }
        startStopButton.setImage(image, for: .normal)
        guard let imageView = startStopButton.imageView else { return }
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Helper methods

    private func startTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.0001,
            repeats: true
        ) { _ in
            self.currentTime -= 0.0001
        }
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    private func restartTimer() {
        stopTimer()
        startTimer()
    }

    private func toggleCurrentPhase() {
        currentPhase = currentPhase == .work ? .rest : .work
    }

    func progressAnimation(duration: TimeInterval) {
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressBarShapeLayer.strokeEnd = 0.0
        progressBarShapeLayer.add(circularProgressAnimation, forKey: "progressAnimation")
    }

    func pauseAnimation(){
        let pausedTime = progressBarShapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        progressBarShapeLayer.speed = 0.0
        progressBarShapeLayer.timeOffset = pausedTime
    }

    func resumeAnimation(){
        let pausedTime = progressBarShapeLayer.timeOffset
        progressBarShapeLayer.speed = 1.0
        progressBarShapeLayer.timeOffset = 0.0
        progressBarShapeLayer.beginTime = 0.0
        let timeSincePause = progressBarShapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        progressBarShapeLayer.beginTime = timeSincePause
    }
}

// MARK: - Constants

fileprivate enum StyleConstants {
    static let backgroundColor = UIColor.white
    static let progressBarFillColor = UIColor.clear
    static let progressBarWorkBackgroundStrokeColor = UIColor(red: 250 / 255, green: 222 / 255, blue: 219 / 255, alpha: 1)
    static let progressBarWorkStrokeColor = UIColor(red: 252 / 255, green: 140 / 255, blue: 128 / 255, alpha: 1)
    static let progressBarRestBackgroundStrokeColor = UIColor(red: 176 / 255, green: 227 / 255, blue: 208 / 255, alpha: 1)
    static let progressBarRestStrokeColor = UIColor(red: 97 / 255, green: 197 / 255, blue: 163 / 255, alpha: 1)
    static let timerLabelFont = UIFont.systemFont(ofSize: 60)
}

fileprivate enum LayoutConstants {
    static let progressBarLineWidth = 5.0
    static let timerLabelOffset = 0.2
    static let startStopButtonOffset = 0.55
    static let startStopButtonImageSize = CGSize(width: 40, height: 40)
    static func getProgressBarRadius(bounds: CGRect) -> Double {
        return bounds.width / 2 * 0.75
    }
}

fileprivate enum Constants {
    static let startPoint = -90.degreesToRadians
    static let endPoint = 270.degreesToRadians
    // Время работы в секундах.
    static let workTime = TimeInterval(5)
    // Время отдыха в секундах.
    static let restTime = TimeInterval(3)
    static let initialPhase = PomodoroPhase.work
}
