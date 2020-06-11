//
//  AsyncOperationCancelling.swift
//  Podcasts
//
//  Created by Олег Черных on 09/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

final class AsyncOperationCanceller {
    private let _cancel: () -> Void
    init(_ cancel: @escaping () -> Void) {
        self._cancel = cancel
    }
    func cancel() {}
}
