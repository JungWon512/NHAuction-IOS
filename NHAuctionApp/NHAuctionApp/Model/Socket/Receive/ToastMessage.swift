//
//  ToastMessage.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

class ToastMessage : ReceiveBase {
    
    //타입코드
    @objc var type:String = ""
    @objc var auctionCode: String = ""
    @objc var msg: String = ""
    
}
