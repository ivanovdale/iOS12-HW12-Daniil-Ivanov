//
//  PomodoroView.swift
//  iOS12-HW12-Daniil-Ivanov
//
//  Created by Daniil (work) on 24.01.2024.
//

import UIKit
import SnapKit

// MARK: - View

final class PomodoroView: UIView {
    private let startStopButtonHandler: () -> Void

    // MARK: - Outlets

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = StyleConstants.timerLabelFont

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

    // MARK: - Init

    init(startStopButtonHandler: @escaping () -> Void) {
        self.startStopButtonHandler = startStopButtonHandler
        super.init(frame: .zero)
        setupView()
        setupHierarchy()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
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
        }
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }

    // MARK: - Actions

    @objc func startStopButtonTapped(sender: UIButton) {
        startStopButtonHandler()
    }

    // MARK: - UI update

    func updateTimerLabel(currentTime: TimeInterval, currentPhase: PomodoroPhase) {
        timerLabel.text = currentTime.time
        timerLabel.textColor = currentPhase.color
    }

    func updateProgressBarBackground(currentPhase: PomodoroPhase) {
        progressBarBackgroundShapeLayer.strokeColor = currentPhase.backgroundColor.cgColor
    }

    func updateProgressBar(currentPhase: PomodoroPhase) {
        progressBarShapeLayer.strokeColor = currentPhase.color.cgColor
    }

    func updateStartStopButton(currentPhase: PomodoroPhase, currentStatus: Status?) {
        startStopButton.tintColor = currentPhase.color

        guard let image = currentStatus?.image ?? Status.defaultImage else { return }
        startStopButton.setImage(image, for: .normal)
        guard let imageView = startStopButton.imageView else { return }
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Animation

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
    static let backgroundColor = UIColor.systemBackground
    static let progressBarFillColor = UIColor.clear
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
}
