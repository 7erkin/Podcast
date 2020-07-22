//
//  URL.swift
//  Podcasts
//
//  Created by Олег Черных on 06/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

// can i do so???
// replace http to https. Is it correct?!
extension URL {
    var isSecure: Bool {
        return self.absoluteString.hasPrefix("https")
    }
    
    var secured: URL {
        if self.isSecure {
            return self
        }
        
        let url = self.absoluteString.replacingOccurrences(
            of: "http",
            with: "https",
            options: [.anchored],
            range: nil
        )
        return URL(string: url)!
    }
    
    var contentSize: Promise<Int64?> {
        var request = URLRequest(
            url: self,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 5.0
        )
        request.httpMethod = "HEAD"
        return Promise { resolver in
            URLSession.shared.dataTask(with: request) { (_, responseOrNil, errorOrNil) in
                guard
                    errorOrNil == nil,
                    let response = responseOrNil as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                else {
                    resolver.fulfill(nil)
                    return
                }

                if let headerValue = response.allHeaderFields["Content-Length"] as? String, let contentLength = Int64(headerValue) {
                    resolver.fulfill(contentLength)
                } else {
                    resolver.fulfill(nil)
                }
            }.resume()
        }
    }
}
