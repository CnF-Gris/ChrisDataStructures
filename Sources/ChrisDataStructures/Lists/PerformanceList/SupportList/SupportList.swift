//
//  File.swift
//  
//
//  Created by Christian Risi on 25/08/22.
//

import Foundation

@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class SupportList<Element> {
    
    @Published private var scrollList: DoublyLinkedList<DoublyLinkedList<Element>>
    private let levelZeroDivider: Int
    
    private var startOffset: Int
    private var endOffset: Int
    
    public var count : Int {scrollList.getFirst()!.count}
    public var isEmpty : Bool {return count == 0}
    
    private var lastItemTaken : (node: DoublyLinkedNode<Element>,index: Int)?
    private var dirty : Bool = true
    private var searchOffset: Int = 0
    
    public convenience init() {
        self.init(divider: 100)
    }
    
    init(divider: Int) {
        startOffset = 0
        endOffset = 0
        levelZeroDivider = divider
        scrollList = DoublyLinkedList()
        scrollList.addLast(DoublyLinkedList<Element>())
    }
    
    //Public functions
    //----------------------------------------------------------------------------
    
    public func addFirst(element: Element) {
        
        addStartOffset()
        scrollList.getFirst()!.addFirst(element)
        
        if ((startOffset % (levelZeroDivider)) == 0) && scrollList.count > 1 {
            addUpperCascaded()
        }
        
        dirty = true
        
    }
    
    public func addLast(element: Element) {
        
        addEndOffset()
        
        scrollList.getFirst()!.addLast(element)
        
        if (endOffset % levelZeroDivider) == 0 {
            
            addUpperCascaded()
        }
        
        dirty = true
        
    }
    
    public func removeFirst() -> Element? {
        let tmp = scrollList.getFirst()!.removeFirst()
        removeUpperCascaded()
        removeStartOffset()
        return tmp
    }
    
    public func removeLast() -> Element? {
        let tmp = scrollList.getFirst()!.removeLast()
        removeUpperCascaded()
        removeEndOffset()
        return tmp
    }
    
    public func getFirst() -> Element? {
        return scrollList.getFirst()!.getFirst()
    }
    
    public func getLast() -> Element? {
        return scrollList.getFirst()!.getLast()
    }
    
    //----------------------------------------------------------------------------
    
    //Subscript functions
    //----------------------------------------------------------------------------
    
    //TODO: If needed add a way to count from the end
    public subscript(position: Int) -> Element {
        
        //Starting from the most external Layer
        if lastItemTaken != nil {
            if abs(distance(from: lastItemTaken!.index, to: position)) == 1 {
                
#if DEBUG
       print("Taking one step at a time")
#endif
                
                if position > lastItemTaken!.index {
                    let tmp = lastItemTaken!.node.next!
                    let tmpIndex = lastItemTaken!.index
                    lastItemTaken = (node: tmp, index: tmpIndex + 1)
                    return tmp.element
                } else {
                    let tmp = lastItemTaken!.node.previous!
                    let tmpIndex = lastItemTaken!.index
                    lastItemTaken = (node: tmp, index: tmpIndex - 1)
                    return tmp.element
                }
                
            }
        }
        
        let tmp = searchWithIndex(position: position)
        lastItemTaken = (node: tmp, index: position)
        return tmp.element
    }
    
    private func searchWithIndex(position: Int) -> DoublyLinkedNode<Element> {
        var counter : Int = scrollList.count - 1
        var tempNode : DoublyLinkedNode<Element> = DoublyLinkedNode()
        var supportNode : ThreeDirectionNode<Element> = ThreeDirectionNode()
        var currentPosition : Int = 0
        
        while scrollList[counter].isEmpty && counter > 0{
            counter = counter - 1
        }
        
        let initialOffset : Int
        if dirty {
            initialOffset = countStartOffset(layer: counter)
        } else {
            initialOffset = searchOffset
        }
        currentPosition = initialOffset
        if scrollList[counter].getFirstNode() is ThreeDirectionNode<Element> {
            supportNode = scrollList[counter].getFirstNode() as! ThreeDirectionNode<Element>
        } else {
            tempNode = scrollList[counter].getFirstNode()!
        }
        
#if DEBUG
        var debugSteps = 0
#endif
        
        if currentPosition == position && !isEmpty {
            while supportNode.down! is ThreeDirectionNode {
                supportNode = supportNode.down! as! ThreeDirectionNode<Element>
            }
            tempNode = supportNode.down!
            
        }
        
        while currentPosition != position {
            
            
            
            if counter > 0 {
                
                let exponential = counter + 1
                
                let remainingDistance = abs(distance(from: currentPosition, to: position))
                
                let stepNeeded = Int(round(Double(remainingDistance) / pow(10, Double(exponential))))
                
                if currentPosition > position {
                    var i = 0
                    var repeatCycle = true
                    while i < stepNeeded && repeatCycle{
                        if supportNode.previous is ThreeDirectionNode<Element> {
#if DEBUG
                            debugSteps = debugSteps + 1
#endif
                            supportNode = supportNode.previous! as! ThreeDirectionNode<Element>
                            i = i + 1
                            
                        } else {
                            repeatCycle = false
                        }
                    }
                    currentPosition = currentPosition - (i * Int(pow(10, Double(exponential))))
                } else {
                    var i = 0
                    var repeatCycle = true
                    while i < stepNeeded && repeatCycle{
                        
                        if supportNode.next is ThreeDirectionNode<Element> {
#if DEBUG
                            debugSteps = debugSteps + 1
#endif
                            supportNode = supportNode.next! as! ThreeDirectionNode<Element>
                            i = i + 1
                            
                        } else {
                            repeatCycle = false
                        }
                    }
                    currentPosition = currentPosition + (i * Int(pow(10, Double(exponential))))
                }
                
                if currentPosition == position {
                    while supportNode.down! is ThreeDirectionNode {
                        supportNode = supportNode.down! as! ThreeDirectionNode<Element>
                    }
                    tempNode = supportNode.down!
                    
                } else {
                    if supportNode.down! is ThreeDirectionNode {
                        supportNode = supportNode.down! as! ThreeDirectionNode<Element>
                    } else {
                        tempNode = supportNode.down!
                    }
                }
                counter = counter - 1
                
            } else {
                if supportNode.down != nil {
                    tempNode = supportNode.down!
                }
                
                let remainingDistance = abs(distance(from: currentPosition, to: position))
                
                if currentPosition > position {
                    for _ in 0..<remainingDistance {
#if DEBUG
                        debugSteps = debugSteps + 1
#endif
                        tempNode = tempNode.previous!
                    }
                    currentPosition = currentPosition - remainingDistance
                } else {
                    for _ in 0..<remainingDistance {
#if DEBUG
                        debugSteps = debugSteps + 1
#endif
                        tempNode = tempNode.next!
                    }
                    currentPosition = currentPosition + remainingDistance
                }
                
            }
        }
        
#if DEBUG
        print("It took \(debugSteps) steps to search for the element")
#endif
        
        return tempNode
        
    }
    
    private func countStartOffset(layer: Int) -> Int {
        
        dirty = false
        
#if DEBUG
        var debugSteps = 0
#endif
        
        var j = layer
        var offset : Int = 0
        
        while j > 0 {
            
            let tmpNode : ThreeDirectionNode<Element>
            
            if scrollList[j].isEmpty {
                return -1
            }
            
            tmpNode = scrollList[j].getFirstNode() as! ThreeDirectionNode<Element>
            
            var node = tmpNode.down
            
            while !(node === scrollList[j - 1].getFirstNode()) {
                
#if DEBUG
                debugSteps = debugSteps + 1
#endif
                
                if j > 1 {
                    offset = offset + Int(pow(10, Double(j)))
                } else {
                    offset = offset + 1
                }
                node = node!.previous
            }
            
            
            j = j - 1
        }
        
#if DEBUG
        print("It took \(debugSteps) steps take the offset")
#endif
        
        searchOffset = offset
        
        return offset
        
    }
    
    private func distance(from: Int, to: Int) -> Int {
        
        return to - from
        
    }
    
    //----------------------------------------------------------------------------
    
    //Private functions
    //----------------------------------------------------------------------------
    
    private func addStartOffset() {
        startOffset = startOffset + 1
        if scrollList[0].count < 100 {
            endOffset = endOffset + startOffset
            startOffset = 0
        }
    }
    
    private func addEndOffset() {
        endOffset = endOffset + 1
    }
    
    private func removeStartOffset() {
        startOffset = startOffset - 1
        if scrollList[0].count < 100 {
            endOffset = endOffset + startOffset
            startOffset = 0
        }
    }
    
    private func removeEndOffset() {
        endOffset = endOffset - 1
    }
    
    private func addUpperCascaded() {
        
        if scrollList.count == 1 {
            scrollList.addLast(DoublyLinkedList<Element>())
        }
        
        if (endOffset % levelZeroDivider) == 0{
            addLastUpperCascaded()
        } else if (startOffset % (levelZeroDivider)) == 0 {
            addFirstUpperCascaded()
        }
        
    }
    
    private func addFirstUpperCascaded() {
        
        startOffset = 0
        
        let node1 = ThreeDirectionNode<Element>()
        node1.down = scrollList[0].getFirstNode()!
        
        scrollList[1].addFirst(node1)
        
        var repeatCycle = true
        var i = 1
        while i < scrollList.count && repeatCycle {
            
            if scrollList[i].count % 10 == 0 {
                
                if scrollList.count == i + 1 {
                    scrollList.addLast(DoublyLinkedList<Element>())
                }
                
                let node = ThreeDirectionNode<Element>()
                node.down = scrollList[i].getFirstNode()
                
                scrollList[i + 1].addFirst(node)
                
            } else {
                repeatCycle = false
            }
            i = i + 1
            
        }
        
    }
    
    private func addLastUpperCascaded() {
        
        endOffset = 0
        let node1 = ThreeDirectionNode<Element>()
        node1.down = scrollList[0].getLastNode()!
        scrollList[1].addLast(node1)
        
        var repeatCycle = true
        var i = 1
        while i < scrollList.count && repeatCycle {
            
            if scrollList[i].count % 10 == 0 {
                
                if scrollList.count == i + 1{
                    scrollList.addLast(DoublyLinkedList<Element>())
                }
                
                let node = ThreeDirectionNode<Element>()
                node.down = scrollList[i].getLastNode()!
                
                scrollList[i + 1].addLast(node)
                
            } else {
                repeatCycle = false
            }
            i = i + 1
        }
    }
    
    //TODO: If the dimension drastically goes low, maybe it would be better to drop some layers
    private func removeUpperCascaded() {
        
        if (endOffset % levelZeroDivider) == 0{
            removeLastUpperCascaded()
        } else if (startOffset % levelZeroDivider) == 0 {
            removeFirstUpperCascaded()
        }
        
    }
    
    private func removeFirstUpperCascaded() {
        
        startOffset = 99
        
        
        
        for i in 1..<scrollList.count {
            
            let node = scrollList[i].getFirstNode() as! ThreeDirectionNode<Element>
            
            if node.down == nil {
                
                let _ = scrollList[i].removeFirst()
                
            }
        }
        
    }
    
    private func removeLastUpperCascaded() {
        
        endOffset = 99
        
        
        
        for i in 1..<scrollList.count {
            
            let node = scrollList[i].getLastNode() as! ThreeDirectionNode<Element>
            
            if node.down == nil {
                
                let _ = scrollList[i].removeLast()
                
            }
        }
        
    }
    
    //----------------------------------------------------------------------------
    
}
