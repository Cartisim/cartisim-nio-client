//
//  ChatRequest.swift
//  Cartisim
//
//  Created by Cole M on 3/9/21.
//  Copyright © 2021 Cole M. All rights reserved.
//

import Foundation

public struct ChatData {
    public let data: Data
    
    internal init(data: Data) {
        self.data = data
    }
    
    public var stringRepresentation: String? {
        return String(data: self.data, encoding: .utf8)
    }
}
