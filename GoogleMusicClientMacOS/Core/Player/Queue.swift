//
//  Queue.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 19/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation

struct Queue<Element> {
    enum Index: Equatable {
        case notStarted
        case index(Int)
        case completed
        
        var value: Int? {
            guard case let .index(i) = self else { return nil }
            return i
        }
        
        func incremented(maxValue: Int) -> Index {
            switch self {
            case .notStarted: return maxValue > 0 ? .index(0) : .notStarted
            case .completed: return .completed
            case .index(let i):
                if i < maxValue - 1 {
                    return .index(i + 1)
                } else {
                    return .completed
                }
            }
        }
        
        func decremented(maxValue: Int) -> Index {
            switch self {
            case .notStarted: return .notStarted
            case .completed: return .index(maxValue - 1)
            case .index(let i):
                if i > 0 {
                    return .index(i - 1)
                } else {
                    return .notStarted
                }
            }
        }
        
        static func == (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case (.notStarted, .notStarted): return true
            case (.completed, .completed): return true
            case let (.index(l), .index(r)): return l == r
            default: return false
            }
        }
    }
    
    private(set) var items: [Element]
    private var currentIndex = Index.notStarted
    
    init(items: [Element]) {
        self.items = items
    }
    
    var current: Element? {
        guard let index = currentIndex.value else { return nil }
        return items[index]
    }
    
    var count: Int { return items.count }
    
    var currentElementIndex: Int? { return currentIndex.value }
    
    var isNotStarted: Bool {
        if case Index.notStarted = currentIndex {
            return true
        } else {
            return false
        }
    }
    
    var isCompleted: Bool {
        if case Index.completed = currentIndex {
            return true
        } else {
            return false
        }
    }
    
    private mutating func incrementIndex() {
        currentIndex = currentIndex.incremented(maxValue: items.count)
    }
    
    private mutating func decrementIndex() {
        currentIndex = currentIndex.decremented(maxValue: items.count)
    }
    
    mutating func next() -> Element? {
        incrementIndex()
        return current
    }
    
    mutating func previous() -> Element? {
        decrementIndex()
        return current
    }
    
    mutating func shuffle(moveToFirst: Int?) {
        guard let newFirstIndex = moveToFirst else {
            items.shuffle()
            currentIndex = .notStarted
            return
        }
        
        let newFirst = items.remove(at: newFirstIndex)
        items.shuffle()
        items.insert(newFirst, at: 0)
        currentIndex = .notStarted
    }
    
    mutating func append(items: [Element]) {
        self.items += items
        if currentIndex == .completed {
            currentIndex = .index(self.items.count - items.count)
        }
    }
    
    mutating func resetIndex() {
        currentIndex = .notStarted
    }
    
    mutating func setIndex(to newIndex: Int) -> Element? {
        guard 0..<items.count ~= newIndex else { return nil }
        currentIndex = .index(newIndex)
        return current
    }
    
    mutating func replace(withNew items: [Element]) {
        self.items = items
        currentIndex = .notStarted
    }
}
