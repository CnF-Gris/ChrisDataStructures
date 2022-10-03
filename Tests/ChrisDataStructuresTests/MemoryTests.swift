//
//  File.swift
//  
//
//  Created by Christian Risi on 22/09/22.
//

import Foundation
import XCTest
import ChrisDataStructures

final class MemoryTests: XCTestCase {
    
    public func testMemoryDeallocation() {
        
        //Here we need to test more for memory allocation
        //There is a small memory Leakage
        memoryAllocation()
        
        for _ in 0...3 {
            memoryAllocation()
        }
    }
    
    private func memoryAllocation() {
        let list = ListArray<Int>()
        
        for i in 0..<1000000 {
            
            let a = Int.random(in: 0...1)
            
            if a == 0 {
                list.addLast(i)
            } else {
                list.addFirst(i)
            }
        }
        
        XCTAssert(list.count == 1000000)
        
//        for _ in 0..<10000 {
//            let a = Int.random(in: 0...1)
//
//            if a == 0 {
//                let _ =  list.removeLast()
//            } else {
//                let _ = list.removeFirst()
//            }
//        }
        
//        XCTAssert(list.count == 0)
    }
    
}
