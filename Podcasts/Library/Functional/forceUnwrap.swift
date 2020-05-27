//
//  forceUnwrap.swift
//  Podcasts
//
//  Created by Олег Черных on 26/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

func forceUnwrap<T>(opt: Optional<T>) -> T {
    return opt!
}
