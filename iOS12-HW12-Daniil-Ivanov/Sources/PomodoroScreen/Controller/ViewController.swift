//
//  ViewController.swift
//  iOS12-HW12-Daniil-Ivanov
//
//  Created by Daniil (work) on 24.01.2024.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - View

    private var pomodoroView: PomodoroView? {
        isViewLoaded ? view as? PomodoroView : nil
    }

    // MARK: - Data

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
                pomodoroView?.progressAnimation(duration: currentTime)
            }
            updateCurrentTimeDependantViews()
        }
    }

    private var currentStatus: Status? {
        didSet {
            updateCurrentStatusDependantViews()
        }
    }


    // MARK: - Lifecycle

    override func loadView() {
        view = PomodoroView(startStopButtonHandler: startStopButtonHandler)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateCurrentTimeDependantViews()
        updateCurrentPhaseDependantViews()
        updateCurrentStatusDependantViews()
    }

    // MARK: - Handlers

    private func startStopButtonHandler() {
        if currentStatus == nil {
            startTimer()
            pomodoroView?.progressAnimation(duration: currentTime)
        } else if currentStatus == .paused {
            startTimer()
            pomodoroView?.resumeAnimation()
        } else if currentStatus == .started {
            stopTimer()
            pomodoroView?.pauseAnimation()
        }

        currentStatus = currentStatus == .started ? .paused : .started
    }

    // MARK: - Update data

    private func updateCurrentTimeDependantViews() {
        pomodoroView?.updateTimerLabel(currentTime: currentTime, currentPhase: currentPhase)
        pomodoroView?.updateProgressBar(currentPhase: currentPhase)
    }

    private func updateCurrentPhaseDependantViews() {
        pomodoroView?.updateTimerLabel(currentTime: currentTime, currentPhase: currentPhase)
        pomodoroView?.updateProgressBarBackground(currentPhase: currentPhase)
        pomodoroView?.updateProgressBar(currentPhase: currentPhase)
        pomodoroView?.updateStartStopButton(currentPhase: currentPhase, currentStatus: currentStatus)
    }

    private func updateCurrentStatusDependantViews() {
        pomodoroView?.updateStartStopButton(currentPhase: currentPhase, currentStatus: currentStatus)
    }

    // MARK: - Helper methods

    private func startTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.0001,
            repeats: true
        ) { _ in self.currentTime -= 0.0001 }
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
}

// MARK: - Constants

fileprivate enum Constants {
   static let initialPhase = PomodoroPhase.work
}
