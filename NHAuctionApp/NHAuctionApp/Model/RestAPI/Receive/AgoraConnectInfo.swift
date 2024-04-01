//
//  AgoraConnectInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/08.
//

import Foundation
import ObjectMapper

class AgoraConnectInfo: Mappable {

    
    var KKO_SVC_ID : String = ""
    var KKO_SVC_KEY : String = ""
    var KKO_SVC_CNT : Int = 4

    required init?(map: Map) {
       
    }

    func mapping(map: Map) {
        self.KKO_SVC_ID <- map["KKO_SVC_ID"]
        self.KKO_SVC_KEY <- map["KKO_SVC_KEY"]
        self.KKO_SVC_CNT <- map["KKO_SVC_CNT"]
    }

}
