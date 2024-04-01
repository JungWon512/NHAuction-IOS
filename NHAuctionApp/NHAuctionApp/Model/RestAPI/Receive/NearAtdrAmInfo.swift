//
//  NearAtdrAmInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/11/19.
//

import Foundation
import ObjectMapper

class NearAtdrAmInfo : Mappable {
    var zimPrice : Int = 0
    var bidPrice : Int = 0

    required init?(map: Map) {
       
    }

    func mapping(map: Map) {
        self.zimPrice <- map["zimPrice"]
        self.bidPrice <- map["bidPrice"]
    }
}
