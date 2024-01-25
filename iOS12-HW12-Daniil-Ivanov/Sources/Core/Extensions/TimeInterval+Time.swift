//
//  TimeInterval+Time.swift
//  iOS12-HW12-Daniil-Ivanov
//
//  Created by Daniil (work) on 25.01.2024.
//

import Foundation

extension TimeInterval {
    var time: String {
        return String(format:"%02d:%02d", Int(self/60),  Int(ceil(truncatingRemainder(dividingBy: 60))) )
    }
}
