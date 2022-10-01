//
//  ComparisonTest.swift
//  
//
//  Created by Christian Risi on 30/09/22.
//

import XCTest
import ChrisDataStructures

final class ComparisonTest: XCTestCase {
    
    func testPerformanceListArray() {
        
        var list = ListArray<Int>()

        let a = 1000000
        let b = 100000
        
        for i in 0..<a {
            
            list.addLast(i)
            
        }
        
        for i in 0..<b {
            
            list.addAfter(position: 10000, item: i)
            
        }
        
        measure {
            list.addAfter(position: 10000, item: 99)
        }
        
        list.addBefore(position: 10000, item: 69)
        
        
    }
    
    func testPerformanceArray() {
        
        var arr = Array<Int>()

        let a = 1000000
        let b = 100000
        
        for i in 0..<a {
            
            arr.append(i)
            
        }
        
        for i in 0..<b {
            
            arr.insert(i, at: 10000)
            
        }
        
        measure {
            arr.insert(99, at: 10000)
        }
        
        arr.insert(69, at: 9999)
        
        
    }
    
    func testPerformanceListArray2() {
        
        var list = ListArray<Int>()

        let a = 1000000
        let b = 100000
        
        for i in 0..<a {
            
            list.addLast(i)
            
        }
        
//        for i in 0..<b {
//
//            list.addAfter(position: 10000, item: i)
//
//        }
//
//        list.addBefore(position: 10000, item: 69)
        
        measure {
            print(list[15199])
        }
    }
    
    func testPerformanceArray2() {
        
        var arr = Array<Int>()

        let a = 1000000
        let b = 100000
        
        for i in 0..<a {
            
            arr.append(i)
            
        }
        
        for i in 0..<b {
            
            arr.insert(i, at: 10000)
            
        }
        
        arr.insert(69, at: 9999)
        
        measure {
            print(arr[10])
        }
    }

}
