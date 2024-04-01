//
//  ResponseBiddingInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class ResponseBiddingInfo : ReceiveBase {
    //타입코드
    @objc var type:String = ""
    
   
    @objc var  auctionHouseCode: String = ""
    
    @objc var  traderMngNum: String = ""
    // 출품 번호
    @objc var  entryNum: String = ""
    // 응찰금액
    @objc var  biddingPrice: String = ""
    
    @objc var  biddingTime: String = ""
    
}
