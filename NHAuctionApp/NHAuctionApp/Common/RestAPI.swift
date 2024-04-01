//
//  RestAPI.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/01.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

/***
 AppVersion 체크하는 RestAPI
 - Parameter result:
 */
func callAppVersion(result: @escaping  (Result<Appversion>)-> Void){
   
    let headers = [
        "Accept" : "application/json;charset=UTF-8",
        "Content-Type" : "application/json"
    ]
    
    let params = [
        "osType" :     "IOS"
    ]


    let appVersionUrl = "\(WEB.HOST)\(WEB.APP_VERSION)"

    Alamofire.request(appVersionUrl,
                          method: .get,
                      parameters: params,
                          headers: headers)
        .responseObject { (response: DataResponse<Appversion>) in
            let appversion = response.result
            result(appversion)
    }
}


/***
 즐겨찾기 RestAPI
 - Parameters:
   - naBzPlc: auctionHouseCode
   - aucClass: entryType
   - userMemNum: getTraderMngNum
   - aucSeq: entryNum
   - result: 결과값
 */
func callFavorite(naBzPlc : String, aucClass :String, userMemNum   :String, aucSeq :String, result:@escaping (Result<Favorite>) -> Void) {
    
    let token = LocalStorage.shared.getUserToken()
    let headers = [
        "Accept" : "application/json;charset=UTF-8",
        "Content-Type" : "application/json",
        "Bearer" : token
    ]
    
    let params = [
        "aucClass" : aucClass,
        "userMemNum" : userMemNum,
        "aucSeq" : aucSeq
    ]

    let favoriteUrl = "\(WEB.HOST)\(String(format: WEB.FAVORITE, arguments: [WEB.VERSION, naBzPlc]))"
    
        Alamofire.request(favoriteUrl,
                          method: .get,
                      parameters: params,
                          headers: headers)
        .responseObject { (response: DataResponse<Favorite>) in
            let favorite = response.result
            result(favorite)
        }
    
}

/***
 AgoraInfo호출
 - Parameter result:
 */
func callAgoraConnect(result:@escaping (Result<AgoraConnect>) -> Void) {
    
    let naBzPlc = LocalStorage.shared.getNaBzPlc()
    let headers = [
        "Accept" : "application/json;charset=UTF-8",
        "Content-Type" : "application/json"
    ]

    let agoraConnectUrl = "\(WEB.HOST)\(String(format: WEB.KAKAO_CONNECT_URL, arguments: [WEB.VERSION, naBzPlc]))"
    
    Alamofire.request(agoraConnectUrl,
                      method: .get,
                  parameters: nil,
                      headers: headers)
    .responseObject { (response: DataResponse<AgoraConnect>) in
        let agoraConnect = response.result
        result(agoraConnect)
    }
}

/***
 근처 경매장 정보 호출하는 RestAPI (현재 사용안함 )
 - Parameters:
   - lvstAucPtcMnNo:
   - aucPrgSq:
   - aucObjDsc:
   - result:
 */
func callNearAtdrAm(lvstAucPtcMnNo   :String, aucPrgSq:String, aucObjDsc:String, result:@escaping (Result<NearAtdrAm>) -> Void) {
    let naBzPlc = LocalStorage.shared.getNaBzPlc()
    let headers = [
        "Accept" : "application/json;charset=UTF-8",
        "Content-Type" : "application/json"
    ]
    
    let params = [
        "naBzplc" : naBzPlc,
        "lvstAucPtcMnNo" : lvstAucPtcMnNo,
        "aucPrgSq" : aucPrgSq,
        "aucObjDsc" : aucObjDsc,
    ]
    
    let neatAtdrAmUrl = "\(WEB.HOST)\(String(format: WEB.NEAR_ATDR_AM_URL, arguments: [WEB.VERSION]))"
    
        Alamofire.request(neatAtdrAmUrl,
                          method: .get,
                      parameters: params,
                          headers: headers)
        .responseObject { (response: DataResponse<NearAtdrAm>) in
            let nearAtdrAm = response.result
            result(nearAtdrAm)
        }
    
}
