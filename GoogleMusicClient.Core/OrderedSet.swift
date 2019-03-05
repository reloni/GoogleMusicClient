//
//  OrderedSet.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 02/03/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

public struct OrderedSet<Element: Hashable> {
    private var objects: [Element] = []
    private var indexOfKey: [Element: Int] = [:]
    
    public init(elements: [Element] = []) {
        elements.forEach {
            add($0)
        }
    }
    
    // O(1)
    public mutating func add(_ object: Element) {
        guard indexOfKey[object] == nil else {
            return
        }
        
        objects.append(object)
        indexOfKey[object] = objects.count - 1
    }
    
    // O(n)
    public mutating func insert(_ object: Element, at index: Int) {
        assert(index < objects.count, "Index should be smaller than object count")
        assert(index >= 0, "Index should be bigger than 0")
        
        guard indexOfKey[object] == nil else {
            return
        }
        
        objects.insert(object, at: index)
        indexOfKey[object] = index
        for i in index+1..<objects.count {
            indexOfKey[objects[i]] = i
        }
    }
    
    // O(1)
    public func object(at index: Int) -> Element {
        assert(index < objects.count, "Index should be smaller than object count")
        assert(index >= 0, "Index should be bigger than 0")
        
        return objects[index]
    }
    
    // O(1)
    public mutating func set(_ object: Element, at index: Int) {
        assert(index < objects.count, "Index should be smaller than object count")
        assert(index >= 0, "Index should be bigger than 0")
        
        guard indexOfKey[object] == nil else {
            return
        }
        
        indexOfKey.removeValue(forKey: objects[index])
        indexOfKey[object] = index
        objects[index] = object
    }
    
    // O(1)
    public func indexOf(_ object: Element) -> Int {
        return indexOfKey[object] ?? -1
    }
    
    // O(n)
    public mutating func remove(_ object: Element) {
        guard let index = indexOfKey[object] else {
            return
        }
        
        indexOfKey.removeValue(forKey: object)
        objects.remove(at: index)
        for i in index..<objects.count {
            indexOfKey[objects[i]] = i
        }
    }
    
    public func all() -> [Element] {
        return objects
    }
}

public extension OrderedSet {
    func indexOfOptioal(_ object: Element?) -> Int? {
        guard let o = object else { return nil }
        return indexOf(o)
    }
}

extension OrderedSet: Equatable {
    public static func == (lhs: OrderedSet, rhs: OrderedSet) -> Bool {
        return lhs.objects == rhs.objects
    }
}
