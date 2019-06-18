//
//  Publisher+System.swift
//  CombineFeedback
//
//  Created by Jacob Enzien on 6/15/19.
//  Copyright © 2019 Jacob Enzien. All rights reserved.
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    
    public static func system<Event>(initial: Output,
                                     scheduler: DispatchQueue = DispatchQueue.main,
                                     reduce: @escaping (Output, Event) -> Output,
                                     feedbacks: [Feedback<Output, Event, DispatchQueue>]) -> AnyPublisher<Output, Never> {
        return _system(initial: initial, scheduler: scheduler, reduce: reduce, feedbacks: feedbacks)
    }
    
    public static func system<Event, S: Scheduler>(initial: Output,
                                     scheduler: S,
                                     reduce: @escaping (Output, Event) -> Output,
                                     feedbacks: [Feedback<Output, Event, S>]) -> AnyPublisher<Output, Never> {
        return _system(initial: initial, scheduler: scheduler, reduce: reduce, feedbacks: feedbacks)
    }
    
    private static func _system<Event, S: Scheduler>(initial: Output,
                                                    scheduler: S,
                                                    reduce: @escaping (Output, Event) -> Output,
                                                    feedbacks: [Feedback<Output, Event, S>]) -> AnyPublisher<Output, Never> {
        return Publishers.Deferred<AnyPublisher<Output, Never>> {
            let state = PassthroughSubject<Output, Never>()
            let events = feedbacks.map { feedback in
                return feedback.events(scheduler, state.eraseToAnyPublisher())
            }
            
            let publisher = events.reduce(Publishers.Empty<Event, Never>(completeImmediately: false).eraseToAnyPublisher()) { (result, event) -> AnyPublisher<Event, Never> in
                return result
                    .merge(with: event)
                    .eraseToAnyPublisher()
            }
            
            return publisher
                .scan(initial, reduce)
                .handleEvents(receiveSubscription: { _ in
                    state.send(initial)
                }, receiveOutput: { (output) in
                    state.send(output)
                }).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}

