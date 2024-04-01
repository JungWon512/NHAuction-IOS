//
//  AppversionInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/01.
//

import Foundation
import ObjectMapper

class AppversionInfo : Mappable{

    
    var  APP_VERSION_ID : Int = 0
    var OS_TYPE:String = ""
    var DEPLOY_DATE:String = ""
    var MAX_VERSION :String = "0.0.0"
    var MIN_VERSION:String = "0.0.0"
    var FSRG_DTM:String = ""
    var FRSGMMN_ENO : String = ""
    var LSCHG_DTM:String = ""
    var LS_CMENO:String = ""
    var NET_HOST:String = "1.201.161.58"
    var NET_PORT:String = "5001"
    
    required init?(map: Map) {
       
    }
    
    func mapping(map: Map) {
        self.APP_VERSION_ID <- map["APP_VERSION_ID"]
        self.OS_TYPE <- map["OS_TYPE"]
        self.DEPLOY_DATE <- map["DEPLOY_DATE"]
        self.MAX_VERSION <- map["MAX_VERSION"]
        self.MIN_VERSION <- map["MIN_VERSION"]
        self.FSRG_DTM <- map["FSRG_DTM"]
        self.FRSGMMN_ENO <- map["FRSGMMN_ENO"]
        self.LSCHG_DTM <- map["LSCHG_DTM"]
        self.LS_CMENO <- map["LS_CMENO"]
        self.NET_HOST <- map["NET_HOST"]
        self.NET_PORT <- map["NET_PORT"]
        
    }
    
    
    
    
}
