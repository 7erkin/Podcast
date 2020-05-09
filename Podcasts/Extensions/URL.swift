//
//  URL.swift
//  Podcasts
//
//  Created by Олег Черных on 06/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

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
}
