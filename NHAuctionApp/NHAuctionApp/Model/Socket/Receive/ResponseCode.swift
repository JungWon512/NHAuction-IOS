//
//  ResponseCode.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class ResponseCode : ReceiveBase {
    //타입코드
    @objc var type:String = ""
    @objc var  auctionHouseCode: String = ""
    // 예외 상황 코드
    @objc var  code: Int = 0
}
