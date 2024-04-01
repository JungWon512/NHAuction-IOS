//
//  ConnectionInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class ConnectionInfo : SendBase {
    //타입코드
    @objc var   type:String = ""
    @objc var  auctionHouseCode: String = ""
    @objc var  traderMngNum: String = ""
    @objc var  token: String = ""
    @objc var  channel: Int = 6001
    @objc var  osType: String = ""

    override init() {
        super.init()
    }
}
