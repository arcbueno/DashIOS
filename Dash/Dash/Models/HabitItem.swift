//
//  HabitItem.swift
//  Dash
//
//  Created by Pedro Bueno on 02/07/25.
//
import Foundation

struct HabitItem : Identifiable, Codable, Hashable{
    let id: String
    let title: String
    let createdAt: Date
    var records: [HabitRecord]
}

struct HabitRecord: Identifiable, Codable, Hashable{
    let id: String
    let habitId: String
    let date: Date
    let done: Bool
}
