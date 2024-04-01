//
//  UserToken.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/10.
//

import Foundation
import ObjectMapper

class UserTokenParsed  : Mappable {
    var userNum : String = ""
    var success : Bool = false
    var auctionCode : String = ""
    var nearestBranch : String = ""
    var auctionCodeName : String = ""
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        self.userNum <- map["userNum"]
        self.success <- map["success"]
        self.auctionCode <- map["auctionCode"]
        self.nearestBranch <- map["nearestBranch"]
        self.auctionCodeName <- map["auctionCodeName"]
    }
    
}
