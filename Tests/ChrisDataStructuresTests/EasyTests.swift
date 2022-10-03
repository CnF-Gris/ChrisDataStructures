import XCTest
import ChrisDataStructures

final class Chris_DataStructuresTests: XCTestCase {
    
    func testAddFirst() throws {
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            list.addFirst(i)
        }
        
        XCTAssert(list.count == 10000)
    }
    
    func testAddLast() throws {
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            list.addLast(i)
        }
        
        XCTAssert(list.count == 10000)
    }
    
    func testAddOnEnd() throws {
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            
            let a = Int.random(in: 0...1)
            
            if a == 0 {
                list.addLast(i)
            } else {
                list.addFirst(i)
            }
        }
        
        XCTAssert(list.count == 10000)
    }
    
    func testRemovalFirst() throws {
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            list.addFirst(i)
        }
        
        for _ in 0..<10000 {
            let _ = list.removeFirst()
        }
        
        XCTAssert(list.count == 0)
    }
    
    func testRemovalLast() throws {
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            list.addLast(i)
        }
        
        for _ in 0..<10000 {
            let _ = list.removeLast()
        }
        
        XCTAssert(list.count == 0)
    }
    
    func testRemovalOnEnd() throws {
        let list = ListArray<Int>()
        
        for i in 0..<10000 {
            
            let a = Int.random(in: 0...1)
            
            if a == 0 {
                list.addLast(i)
            } else {
                list.addFirst(i)
            }
        }
        
        for _ in 0..<10000 {
            let a = Int.random(in: 0...1)
            
            if a == 0 {
                let _ =  list.removeLast()
            } else {
                let _ = list.removeFirst()
            }
        }
        
        XCTAssert(list.count == 0)
    }
    
    
}
