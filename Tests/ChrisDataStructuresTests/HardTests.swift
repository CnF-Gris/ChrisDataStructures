//
//  HardTests.swift
//  
//
//  Created by Christian Risi on 22/09/22.
//

import XCTest
import ChrisDataStructures

final class HardTests: XCTestCase {
    
    func testRandomAdd() throws {
        
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            
            let a = Int.random(in: 0...1)
            
            if a == 0 {
                list.addLast(i)
            } else {
                list.addFirst(i)
            }
        }
        
        for i in 0..<1000 {
            
            let a = Int.random(in: 0...1)
            let b = Int.random(in: 1000...1200)
            if a == 0 {
                list.addBefore(position: b, item: i)
            } else {
                list.addAfter(position: b, item: i)
            }
            
        }
        
        XCTAssert(list.count == 11000)
    }
    
    func testRandomAccessLast() {
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            list.addLast(i)
        }
        
        let a = Int.random(in: 0..<10000)
        
        XCTAssert(list[a] == a)
        
        
    }
    
    func testRandomAccessFirst() {
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            list.addFirst(i)
        }
        
        for i in 0..<10000 - 1 {
            
            XCTAssert(list[i] > list[i + 1])
            
        }
        
        XCTAssert(list[0] == 9999)
        XCTAssert(list[9999] == 0)
        
        
    }
    
    func testRandomAccessWithRandomInsertions() {
        
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            
            
            list.addLast(i)
        }
        
        print(list[5109])
        print(list[5110])
        
        list.addAfter(position: 5109, item: 69)
        
        
        print(list[5109])
        print(list[5110])
        
        XCTAssert(list[5110] == 69)
    }
    
    
    
}
