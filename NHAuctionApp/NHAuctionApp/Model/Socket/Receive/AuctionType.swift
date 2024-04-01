//
//  AuctionType.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/11/09.
//

import Foundation

class AuctionType : ReceiveBase {
    
    //
    //타입코드
    @objc var type:String = ""
    
    // 조합구분코드
    @objc var  auctionHouseCode: String = ""
    // 출품 번호
    @objc var  auctionType: String = "20" //10 -> 일괄 경매 20 -> 단일 경매
}
