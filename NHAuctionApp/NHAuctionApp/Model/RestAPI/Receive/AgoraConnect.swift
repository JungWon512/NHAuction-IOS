//
//  KakaoConnect.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/08.
//

import Foundation
import ObjectMapper

class AgoraConnect : Mappable {
    
    var success : Bool = false
    var message : String = ""
    var kkoInfo : AgoraConnectInfo?
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        self.success <- map["success"]
        self.message <- map["message"]
        self.kkoInfo <- map["kkoInfo"]
    }
}
