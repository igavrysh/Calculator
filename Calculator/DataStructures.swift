//
//  Stack.swift
//  Calculator
//
//  Created by Gavrysh on 7/16/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import Foundation

struct Stack<T> {
    private var values: [T] = []
    
    mutating func push(_ value: T) {
        values.insert(value, at: 0)
    }
    
    mutating func pop() -> T? {
        return values.remove(at: 0)
    }
}

struct Queue<T>: Sequence {
    private var values: [T] = []

    func makeIterator() -> IndexingIterator<Array<T>> {
        return values.makeIterator()
    }
    
    func valuesArray() -> [T] {
        return Array.init(self.values)
    }
    
    mutating func enqueue(_ value: T) {
        self.values.append(value)
    }
    
    mutating func dequeue() -> T? {
        return self.isEmpty ? nil : self.values.removeFirst()
    }
    
    mutating func addValues(in array: [T]) {
        var values = array
        
        while values.count > 0 {
            self.enqueue(values.removeFirst())
        }
    }
    
    @discardableResult
    mutating func removeLast() -> T? {
        return self.isEmpty ? nil : self.values.removeLast()
    }

    mutating func addFirst(_ value: T) {
        self.values.insert(value, at: 0)
    }
    
    
    var isEmpty: Bool {
        return self.values.isEmpty
    }
    
    var count: Int {
        return self.values.count
    }
    
    var last: T? {
        return self.values.last
    }
    
    var first: T? {
        return self.values.first
    }
    
    subscript(index: Int) -> T {
        return self.values[index]
    }
}
