//
//  WeeklyItem.swift
//  Dash
//
//  Created by Pedro Bueno on 26/06/25.
//

import Foundation

struct WeeklyItem : Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let done: Bool
    let createdAt: Date
}
