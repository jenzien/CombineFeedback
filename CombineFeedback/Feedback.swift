//
//  Feedback.swift
//  CombineFeedback
//
//  Created by Jacob Enzien on 6/15/19.
//  Copyright © 2019 Jacob Enzien. All rights reserved.
//

import Foundation
import Combine

internal protocol AnySchedulerBox {
    func unbox<S: Scheduler>() -> S?
}

internal struct ConcreteAnySchedulerBox<Base: Scheduler>: AnySchedulerBox {
    let base: Base
    
    func unbox<S: Scheduler>() -> S? {
        return self as? S
    }
}

public struct AnyScheduler {
    let boxedScheduler: AnySchedulerBox
    
    public init<S>(scheduler: S) where S: Scheduler {
        boxedScheduler = ConcreteAnySchedulerBox(base: scheduler)
    }
}

extension Scheduler {
    func eraseToAnyScheduler() -> AnyScheduler {
        return AnyScheduler(scheduler: self)
    }
}

public struct Feedback<State, Event, S: Scheduler> {
    let events: (S, AnyPublisher<State, Never>) -> AnyPublisher<Event, Never>
    
    public init(events: @escaping (S, AnyPublisher<State, Never>) -> AnyPublisher<Event, Never>) {
        self.events = events
    }
}
