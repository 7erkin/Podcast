//
//  Observer.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

protocol Observer {
    associatedtype AcceptedEvent
    func notify(withEvent event: AcceptedEvent)
}
