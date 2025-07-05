//
//  CalendarExtension.swift
//  Dash
//
//  Created by Pedro Bueno on 05/07/25.
//

import Foundation

extension Calendar {
    /*
     Week boundary is considered the start of
     the first day of the week and the end of
     the last day of the week
     */
    
    func currentWeekBoundary() -> (startOfWeek: Date?, endOfWeek: Date?)? {
        return weekBoundary(for: Date())
    }
    
    func weekBoundary(for date: Date) -> (startOfWeek: Date?, endOfWeek: Date?)? {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        guard let startOfWeek = self.date(from: components) else {
            return nil
        }
        
        let endOfWeekOffset = weekdaySymbols.count - 1
        let endOfWeekComponents = DateComponents(day: endOfWeekOffset, hour: 23, minute: 59, second: 59)
        guard let endOfWeek = self.date(byAdding: endOfWeekComponents, to: startOfWeek) else {
            return nil
        }
        
        return (startOfWeek, endOfWeek)
    }
}
