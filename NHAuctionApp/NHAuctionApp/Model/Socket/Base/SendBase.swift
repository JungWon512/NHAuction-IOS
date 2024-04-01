//
//  SendBase.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation
import UIKit
/***
 전송할 패킷을 설정  Model
 */
class SendBase {
    init(){
        
    }
    func toString() -> String {
        var result :String = ""
        var elements : [String] = []
        
        for property in Mirror(reflecting: self).children {
            elements.append("\(property.value)")
        }
        result = elements.joined(separator: SOCKET_COMMON.DELIMITER)
        result.append(SOCKET_COMMON.TERMINATOR)
        return result
    }
}
