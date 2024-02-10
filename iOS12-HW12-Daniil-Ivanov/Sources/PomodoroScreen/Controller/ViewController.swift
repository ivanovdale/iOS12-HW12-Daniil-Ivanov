//
//  ViewController.swift
//  iOS12-HW12-Daniil-Ivanov
//
//  Created by Daniil (work) on 24.01.2024.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Lifecycle

    override func loadView() {
        view = PomodoroView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

