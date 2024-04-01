//
//  UserInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/10.
//

import Foundation
import ObjectMapper

//"{\"userToken\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJhdWN0aW9uSG91c2VDb2RlIjoiODgwODk5MDY1NjY1NiIsInVzZXJSb2xlIjoiQklEREVSIiwidXNlck1lbU51bSI6IjMyNCIsImV4cCI6MTYzMzg3Nzk5OX0.74BTjPvGpjPhdJ3BFttLD5PlNace7BXondsd9MTX_kGYkxpoYk-ZcjoJeaoXWtR642f6BEm2jLzP_mLHiWc8Jw\",\"auctionCode\":\"8808990656656\",\"userName\":null,\"userNum\":\"324\",\"nearestBranch\":\"8808990657202\"}"
/***
 UserInfo Model
 */
class UserInfo : Mappable {
    var userToken : String = ""
    var auctionCode : String = ""
    var userName : String = ""
    var userNum : String = ""
    var nearestBranch : String = ""
    
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        self.userToken <- map["userToken"]
        self.auctionCode <- map["auctionCode"]
        self.userName <- map["userName"]
        self.userNum <- map["userNum"]
        self.nearestBranch <- map["nearestBranch"]
    }
    
}
