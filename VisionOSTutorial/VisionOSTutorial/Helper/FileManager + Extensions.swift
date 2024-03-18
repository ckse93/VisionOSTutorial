//
//  FileManager + Extensions.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/14/24.
//

import Foundation

extension FileManager {
    static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
}
