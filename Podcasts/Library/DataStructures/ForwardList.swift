//
//  List.swift
//  Podcasts
//
//  Created by Олег Черных on 17/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class ForwardListNode<Element> {
    let value: Element
    var nextNode: ForwardListNode<Element>?
    init(value: Element) {
        self.value = value
    }
}

struct ForwardList<Element: Equatable> {
    private var headNode: ForwardListNode<Element>?
    private var tailNode: ForwardListNode<Element>?
    
    mutating func pushBack(value: Element) {
        let node = ForwardListNode(value: value)
        if headNode == nil {
            headNode = node
            tailNode = node
            return
        }
        
        tailNode?.nextNode = node
        tailNode = node
    }
    
    mutating func popFront() -> Element? {
        if headNode == nil {
            return nil
        }
        
        let node = headNode
        // one element in list
        if headNode === tailNode {
            headNode = nil
            tailNode = nil
        } else {
            headNode = headNode?.nextNode
        }
        
        return node?.value
    }
}

extension ForwardList: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
    init(arrayLiteral elements: Element...) {
        elements.forEach { self.pushBack(value: $0) }
    }
}

