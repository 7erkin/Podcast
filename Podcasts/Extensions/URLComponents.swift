//
//  URLComponents.swift
//  Podcasts
//
//  Created by Олег Черных on 13/07/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension URLComponents {
    static func create(string: String, withQueryItems queryItems: [URLQueryItem]) -> URLComponents? {
        if var urlComponents = URLComponents(string: string) {
            urlComponents.queryItems = queryItems
            return urlComponents
        }
        return nil
    }
}
