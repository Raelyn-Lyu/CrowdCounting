//
//  newExtension.swift
//  CrowdCounting
//
//  Created by Raelyn Lyu on 29/4/19.
//  Copyright © 2019 Raelyn Lyu. All rights reserved.
//

import Foundation
import UIKit

extension String{
    
    public func utf8() -> Data{
        return self.data(using:String.Encoding.utf8)!
    }
    
}

extension Float{
    public func utf8() -> Data{
        return "\(self)".data(using: String.Encoding.utf8)!
    }
}

extension Double{
    public func utf8() -> Data{
        return "\(self)".data(using: String.Encoding.utf8)!
    }
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

