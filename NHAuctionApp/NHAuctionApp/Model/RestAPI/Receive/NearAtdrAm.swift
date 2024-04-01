//
//  NearAtrmAm.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/11/19.
//

import Foundation
import ObjectMapper

class NearAtdrAm : Mappable {
    var success : Bool = false
    var message : String = ""
    var data : NearAtdrAmInfo?
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        self.success <- map["success"]
        self.message <- map["message"]
        self.data <- map["data"]
    }
}
