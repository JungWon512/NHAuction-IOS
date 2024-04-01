//
//  ShowEntryInfo.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class ShowEntryInfo : ReceiveBase {
    //타입코드
    @objc var type:String = ""
    
        // 조합구분코드
    @objc var  auctionHouseCode: String = ""
    @objc var  one: String = ""
    @objc var  two: String = ""
    @objc var  three: String = ""
    @objc var  four: String = ""
    @objc var  five: String = ""
    @objc var  six: String = ""
    @objc var  seven: String = ""
    @objc var  eight: String = ""
    @objc var  nine: String = ""
    @objc var  ten: String = ""
    @objc var  unitType: String = "" // 원단위 구분
}



func actShowEntryInfo(showEntryInfo:ShowEntryInfo) -> (Bool,[String]) {
    
    
    // [Int] 의 경우 preference에 저장하고 읽을수가 없어서 String으로 저장
    var returnVal : (Bool, [String])
    var headerInfo : [String] = []
    
    returnVal.0 = false
    returnVal.1 = []
    returnVal.0 = true
//    for elem in splited {
//        if splited.firstIndex(of: elem)! > 1 {
//            headerInfo.append(elem)
//        }
//    }
//
//
    headerInfo.append(String(showEntryInfo.one))
    headerInfo.append(String(showEntryInfo.two))
    headerInfo.append(String(showEntryInfo.three))
    headerInfo.append(String(showEntryInfo.four))
    headerInfo.append(String(showEntryInfo.five))
    headerInfo.append(String(showEntryInfo.six))
    headerInfo.append(String(showEntryInfo.seven))
    headerInfo.append(String(showEntryInfo.eight))
    headerInfo.append(String(showEntryInfo.nine))
    headerInfo.append(String(showEntryInfo.ten))
    
    returnVal.1 = headerInfo
        
    return returnVal
    
}
