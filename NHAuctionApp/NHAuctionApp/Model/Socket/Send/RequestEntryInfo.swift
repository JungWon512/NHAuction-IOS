//
//  RequestEntryInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class RequestEntryInfo : SendBase {
    //타입코드
    @objc var   type:String = ""
    @objc var  auctionHouseCode: String = ""
    @objc var  traderMngNum: String = ""
    @objc var  entryNum: String = "" 
    override init() {
        super.init()
    }
}
