//
//  ActionCountDown.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class ActionCountDown : ReceiveBase {
    //타입코드
    @objc var type:String = ""
     // 조합구분코드
    @objc var  auctionHouseCode: String = ""
     // R 준비, C 카운트 다운, F 완료
    @objc var  status: String = ""
    @objc var  sec: Int = 0 // 카운트 다운 시간
}
