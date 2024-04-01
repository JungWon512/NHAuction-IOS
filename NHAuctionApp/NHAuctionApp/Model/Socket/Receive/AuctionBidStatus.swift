//
//  AuctionBidStatus.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/11/08.
//

import Foundation

class AuctionBidStatus : ReceiveBase {
    //
    //타입코드
    @objc var type:String = ""
    
    // 조합구분코드
    @objc var  auctionHouseCode: String = ""
    // 출품 번호
    @objc var  entryNum: String = ""
    @objc var  biddingStatus: String = "F"
}
