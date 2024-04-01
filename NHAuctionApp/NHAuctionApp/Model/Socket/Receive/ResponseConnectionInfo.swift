//
//  ResponseConnectionInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class ResponseConnectionInfo : ReceiveBase {
    
    //타입코드
    @objc var type:String = ""
    // 조합구분코드
    @objc var auctionHouseCode: String = ""
    
    // 접속결과코드
    @objc var connectionCode: Int = 2001
    
    @objc var traderMngNum: String = ""
    
    
    //화면 상단의 참가번호
    @objc var userNum: String = ""
}
