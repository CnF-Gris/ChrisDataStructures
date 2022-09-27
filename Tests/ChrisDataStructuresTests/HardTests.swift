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
        
        let a1 = 10000
        let a2 = 10000
        
        let list = ListArray<Int>()
        
        for i in 0..<a1 {
            
            let a = Int.random(in: 0...1)
            
            if a == 0 {
                list.addLast(i)
            } else {
                list.addFirst(i)
            }
        }
        
        for i in 0..<a2 {
            
            let a = Int.random(in: 0...1)
            let b = Int.random(in: 1000...1200)
            if a == 0 {
                list.addBefore(position: b, item: i)
            } else {
                list.addAfter(position: b, item: i)
            }
            
        }
        
        XCTAssert(list.count == (a1 + a2))
    }
    
    func testRandomAccessWithOneRandomInsertionAfter() {
        
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            
            
            list.addLast(i)
        }
        
        list.addAfter(position: 5109, item: 69)
        
        XCTAssert(list[5110] == 69)
    }
    
    func testRandomAccessWithOneRandomInsertionBefore() {
        
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            
            
            list.addLast(i)
        }
        
        list.addBefore(position: 5109, item: 60)
        list.addBefore(position: 5109, item: 60)
        list.addBefore(position: 5109, item: 60)
        list.addBefore(position: 5109, item: 69)
        
        XCTAssert(list[5109] == 69)
    }
    
    func testRandomAccessWithRandomInsertionsBefore() {
        
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            
            
            list.addLast(i)
        }
        
        for _ in 0...140 {
            list.addBefore(position: 5109, item: 60)
        }
        
        print(list[5108])
        print(list[5109])
        
        list.addBefore(position: 5109, item: 69)
        
        print(list[5108])
        print(list[5109])
        
        XCTAssert(list[5109] == 69)
    }
    
    
    
}
