//
//  RetryTargetInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

// 사용안함
class RetryTargetInfo : ReceiveBase {
    //
    //타입코드
    @objc var type:String = ""
    
    // 조합구분코드
    @objc var  auctionHouseCode: String = ""
    // 출품 번호
    @objc var  num: String = ""
    @objc var  retryBidders: String = ""
    
}
