//
//  Bidding.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class Bidding : SendBase {
    
    //타입코드
    @objc var type:String = ""
    // 조합구분코드
    @objc var auctionHouseCode: String = ""
    // 접속 채널
    @objc var osType: String = ""
    // 거래 경매회원번호(거래인번호)
    @objc var traderMngNum : String = ""
    // 경매참가번호
    @objc var userNum: String = ""
    // 출품 번호
    @objc var entryNum: String = ""
//    // 응찰 금액
    @objc var price: Int = 0
    // 신규 응찰 여부
    @objc var newBiddingYn: String = "Y"
    // 시간
    @objc var time : Int = 0
    
    override init() {
        super.init()
    }
}
