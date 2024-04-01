//
//  CancelBidding.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class CancelBidding : SendBase {
    
    //타입코드
    @objc var   type:String = ""
    @objc var   auctionHouseCode: String = "" // 조합구분코드
    @objc var   entryNum: String = ""
    @objc var   traderMngNum : String = ""
    @objc var   userNum: String = ""
    @objc var   osType: String = ""
    @objc var   time: Int = 0
}
