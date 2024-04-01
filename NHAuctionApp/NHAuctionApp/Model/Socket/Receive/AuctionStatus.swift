//
//  AuctionStatus.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class AuctionStatus : ReceiveBase {
    //타입코드
    @objc var type:String = ""
    // 조합구분코드
    @objc var  auctionHouseCode: String = ""
    // 출품 번호
    @objc var  num: String = ""
    // 경매회차
    @objc var  auctionRound : String = ""
    // 시작가
    @objc var  currentPrice: String = ""
    // 현재응찰자수
    @objc var  biddingCnt: String = ""
    // 경매상태(NONE / READY / START / PROGRESS / PASS / COMPLETED / FINISH)
    @objc var  status: Int = 0
    // 1순위회원번호
    @objc var  firstRankNum: String = ""
    // 2순위회원번호
    @objc var  secondRankNum: String = ""
    // 3순위회원번호
    @objc var  thirdRankNum: String = ""
    // 경매진행완료출품수
    @objc var  auctionCompletedCnt: String = ""
    // 경매잔여출품수
    @objc var  auctionResidualCnt: String = ""
    
}
