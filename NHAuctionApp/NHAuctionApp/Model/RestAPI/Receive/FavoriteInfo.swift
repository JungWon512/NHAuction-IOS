//
//  FavoriteInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/01.
//

import Foundation
import ObjectMapper

class FavoriteInfo: Mappable {

    
    var SBID_UPR :Int = 0
    

    required init?(map: Map) {
       
    }

    func mapping(map: Map) {
        self.SBID_UPR <- map["SBID_UPR"]
        
        
    }

}
