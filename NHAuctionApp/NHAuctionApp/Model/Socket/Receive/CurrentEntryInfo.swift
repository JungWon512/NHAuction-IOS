//
//  CurrentEntryInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class CurrentEntryInfo : ReceiveBase {
    //타입코드
    @objc var type:String = ""
    // 조합구분코드
    @objc var  auctionHouseCode: String = ""
    // 출품번호
    @objc var  entryNum: String = ""
    // 경매회차
    @objc var  auctionRound : String = ""
    // 경매대상구분코드 (1 : 송아지 / 2 : 비육우 / 3 : 번식우)
    @objc var  entryType: String = ""
    
    // 축산개체관리번호
    @objc var  indNum: String = ""
    // 축산축종구분코드
    @objc var  indMngCd: String = ""
    // 농가식별번호
    @objc var  fhsNum: String = ""
    // 농장관리번호
    @objc var  farmMngNum: String = ""
    // 농가명
    @objc var  exhibitor: String = ""
    
    // 브랜드명
    @objc var  brandName: String = ""
    // 생년월일
    @objc var  entryBirth: String = ""
    // KPN번호
    @objc var  entryKpn: String = ""
    // 개체성별코드
    @objc var  entryGender: String = ""
    // 어미소구분코드
    @objc var  motherTypeCode: String = ""
    
    // 어미소축산개체관리번호
    @objc var  motherObjNum: String = ""
    // 산차
    @objc var  cavingNum: Int = 0
    
    @objc var  pregnancyMonths : String = ""
    // 계대
    @objc var  pasgQcn: String = ""
    // 계체식별번호
    @objc var  objIdNum: String = ""
    
    // 축산개체종축등록번호
    @objc var  objRegNum: String = ""
    // 등록구분번호
    @objc var  objRegTypeNum: String = ""
    // 출하생산지역
    @objc var  productionArea: String = ""
    // 친자검사결과여부
    @objc var  isPaternalExamination: String = ""
    //신규여부
    @objc var  IsNew: String = ""
    
    // 우출하중량
    @objc var  weight: String = ""
    // 최초최저낙찰한도금액
    @objc var  initPrice: Int = 0
    // 최저낙찰한도금액
    @objc var  lowPrice: Int = 0
    // 비고내용
    @objc var  note: String = ""
    // 낙유찰결과
    @objc var  biddingResult: String = ""
    
    // 낙찰자
    @objc var  succBidder: String = ""
    // 낙찰금액
    @objc var  succBidPrice: String = ""
    // 응찰일
    @objc var  biddingDate: String = ""
    // 마지막출품여부
    @objc var  isLastEntry: String = ""
}
