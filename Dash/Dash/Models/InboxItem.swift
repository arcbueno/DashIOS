//
//  InboxItem.swift
//  Dash
//
//  Created by Pedro Bueno on 01/07/25.
//

import Foundation

struct InboxItem : Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let done: Bool
    let createdAt: Date
}
