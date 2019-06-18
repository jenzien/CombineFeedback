//
//  ContentSystem.swift
//  ExampleApp
//
//  Created by Jacob Enzien on 6/17/19.
//  Copyright © 2019 Jacob Enzien. All rights reserved.
//

import Foundation
import Combine
import CombineFeedback
import SwiftUI

final class ContentSystem: BindableObject {
    enum Event {
        case increment
        case decrement
    }
    
    private(set) var state: Int
    let didChange = PassthroughSubject<Void, Never>()
    
    let increment: PassthroughSubject<Void, Never>
    let decrement: PassthroughSubject<Void, Never>
    let system: AnyPublisher<Int, Never>
    
    init(initialCount: Int) {
        let incrementSubject = PassthroughSubject<Void, Never>()
        let decrementSubject = PassthroughSubject<Void, Never>()
        let increment = Feedback<Int, Event, DispatchQueue> { (scheduler, state) -> AnyPublisher<Event, Never> in
            return incrementSubject.map{_ in .increment}.eraseToAnyPublisher()
        }
        
        let decrement = Feedback<Int, Event, DispatchQueue> { (scheduler, state) -> AnyPublisher<Event, Never> in
            return decrementSubject.map{_ in .decrement}.eraseToAnyPublisher()
        }
        
        self.state = initialCount
        self.increment = incrementSubject
        self.decrement = decrementSubject
        
        self.system = AnyPublisher<Int, Never>.system(initial: initialCount, reduce: { (count, event) -> Int in
            var state = count
            switch event {
            case .increment:
                state += 1
            case .decrement:
                state -= 1
            }
            return state
        }, feedbacks: [increment, decrement])
        _ = system.sink(receiveValue: {count in
            self.state = count
            self.didChange.send()
        })
    }
}
