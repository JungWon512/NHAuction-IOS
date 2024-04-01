//
//  Favorite.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/01.
//

import Foundation
import ObjectMapper

class Favorite : Mappable {
    
    var success : Bool = false
    var message : String = ""
    var info : FavoriteInfo?
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        self.success <- map["success"]
        self.message <- map["message"]
        self.info <- map["info"]
    }
}
