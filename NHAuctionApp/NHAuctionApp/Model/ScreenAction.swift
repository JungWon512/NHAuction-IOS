//
//  ScreenAction.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/03.
//

import Foundation
/***
 화면동작용 ScreenAction Model
 */
class ScreenAction {
    
    var success : Bool = false
    var type: String = ""
    var toastMessage : String = ""
    var toastMessageBig : String = ""
    var attributedString : NSMutableAttributedString = NSMutableAttributedString()
    var extraString : String = ""
    var extraInt : Int = 0
    var extraBool : Bool = false
    var statusToast : NSMutableAttributedString = NSMutableAttributedString()
    var forceBackString : String = ""
    var oneButtonString : String = ""
}
