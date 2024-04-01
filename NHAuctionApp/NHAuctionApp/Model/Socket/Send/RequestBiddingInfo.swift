//
//  RequestBiddingInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class RequestBiddingInfo : SendBase {
    //타입코드
    @objc var    type:String = ""
    @objc var    auctionHouseCode: String = ""
            // 거래인 관리 번호
    @objc var    traderMngNum: String = ""
            // 경매 참여 번호
    @objc var    userNum: String = ""
            
    @objc var    entryNum : String = ""
    
    override init() {
        super.init()
    }
}
