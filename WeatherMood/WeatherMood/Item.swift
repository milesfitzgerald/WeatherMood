//
//  Item.swift
//  WeatherMood
//
//  Created by Miles Fitzgerald on 2/20/26.
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
