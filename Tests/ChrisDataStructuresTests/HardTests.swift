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
    
    func testRandomAccess() {
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            list.addLast(i)
        }
        
        let a = Int.random(in: 0..<10000)
        
        let result = list[a]
        print(a)
        print(result)
        XCTAssert(list[a] == a)
        
        
    }
    
    
    
}
