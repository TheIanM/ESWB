//
//  Item.swift
//  Emotional Support Water Bottle
//
//  Created by devian on 2026-04-28.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
