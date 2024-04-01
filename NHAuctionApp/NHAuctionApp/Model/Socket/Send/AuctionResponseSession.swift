//
//  AuctionResponseSession.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/28.
//

import Foundation

class AuctionResponseSession : SendBase {
    
    //타입코드
    @objc var  type:String = "AA"
    @objc var  userNum : String = ""
    @objc var  channel: Int = 6001
    @objc var  osType : String = ""
    override init() {
        super.init()
    }
}
