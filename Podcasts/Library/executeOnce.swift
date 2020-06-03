//
//  executeOnce.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

func executeOnce(_ function: @escaping () -> Void) -> () -> Void {
    let _flag = Atomic<Bool>(false)
    return {
        if !_flag.value {
            _flag.mutate { $0 = true }
            function()
        }
    }
}
