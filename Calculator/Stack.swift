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

struct Queue<T> {
    private var values: [T] = []
    
    mutating func enqueue(_ value: T) {
        self.values.append(value)
    }
    
    mutating func dequeue() -> T? {
        return self.isEmpty ? nil : self.values.removeFirst()
    }
    
    var isEmpty: Bool {
        return self.values.isEmpty
    }
    
    var count: Int {
        return self.values.count
    }
}
