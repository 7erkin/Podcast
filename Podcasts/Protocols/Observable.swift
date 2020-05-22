//
//  Observable.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

protocol Observable {
    associatedtype EmittedEvent
    associatedtype Subscriber: Observer where Subscriber.AcceptedEvent == EmittedEvent
    func subscribe(subscriber: Subscriber)
    func unsubscribe(subscriber: Subscriber)
}
