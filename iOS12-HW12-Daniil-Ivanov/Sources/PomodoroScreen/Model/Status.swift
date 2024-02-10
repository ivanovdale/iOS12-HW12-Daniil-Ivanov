//
//  Status.swift
//  iOS12-HW12-Daniil-Ivanov
//
//  Created by Daniil (work) on 10.02.2024.
//

import Foundation
import UIKit

enum Status {
    case paused, started
}

extension Status {
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
