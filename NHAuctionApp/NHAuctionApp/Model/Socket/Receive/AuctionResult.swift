//
//  AuctionResult.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class AuctionResult : ReceiveBase {
    
    //타입코드
    @objc var type:String = ""
    // 조합구분코드
    @objc var  auctionHouseCode: String = ""
    // 출품 번호
    @objc var  entryNum: Int = 0
    // 낙/유찰결과코드
    @objc var  auctionResultCode: String = ""
    //  낙찰자회원번호(거래인번호)
    @objc var  traderMngNum: String = ""
    // 낙찰자경매참가번호
    @objc var  userNum: String = ""
    
    @objc var  price: String = ""
}

///***
// 경매결과*/
//func actAuctionResult(auctionResult:AuctionResult) -> (Bool,NSMutableAttributedString,String ) {
//    var returnVal : (Bool,NSMutableAttributedString,String ) = (false, NSMutableAttributedString(string: "서비스 준비중입니다."),"")
//    
//        
//        
//        var auctionResultCode = auctionResult.auctionResultCode
//        
//        var extra1 = ""
//        var extra2 = ""
//        
//        var checkCode = 258000
//        
//        switch auctionResult.auctionResultCode {
//        case "11":
//                
//            break
//        case "22":
//            
//            if( auctionResult.auctionResultCode == "22" ){
//                
//                checkCode = AUCTION_STATE.SUCCESS_BID.code()
//            } else {
//                checkCode = AUCTION_STATE.OTHER_SUCCESS_BID.code()
//            }
//          break
//        case "23":
//            checkCode = AUCTION_STATE.PENDING_BID.code()
//            break
//            
//          
//            
//        default:
//            break
//        }
////
//        returnVal.1 = settingStatusMessage(statusCode:checkCode,extra1:extra1,extra2:extra1).0
//        
//        returnVal.0 = true
//    
//    return returnVal
//}
