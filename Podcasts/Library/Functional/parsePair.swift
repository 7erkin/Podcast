//
//  tupleRetrieve.swift
//  Podcasts
//
//  Created by Олег Черных on 26/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

func parseKeyPair<X, Y>(_ pair: (X, Y)) -> X { pair.0 }
func parseValuePair<X, Y>(_ pair: (X, Y)) ->Y { pair.1 }
