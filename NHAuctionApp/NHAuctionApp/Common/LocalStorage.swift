//
// Created by Sunyoung Choi on 2021/08/27.
//

import Foundation
import UIKit

private struct KEY {

    static let SPEAKER_ON_OFF = "speakerOnOff"
    static let ENTRY_HEADER_INDEX = "entryHeaderIndex"
    static let USER_NUM = "userNum"
    static let TRADER_MNG_NUM = "traderMngNum"
    static let USER_TOKEN = "userToken"
    static let NET_HOST = "netHost"
    static let NET_PORT = "netPort"
    static let NEAREST_BRANCH = "nearestBranch"
    static let NA_BZ_PLC = "naBzPlc"
    static let AGORA_APP_ID = "agoraAppId"
    static let IS_SAME_NEAREST = "isSameNearest"
    static let IS_BACKGROUND = "isBackground"
    static let IS_AGREE_PERMISSION = "isAgreePermission"
    static let IS_BATCH_SELECTION = "isBatchSelection"
    static let IS_DYNAMICLINKS = "isDynamicLinks"
}

/***
 어플리케이션이 값을 저장하는 method
 */
class LocalStorage: NSObject {

    static var shared = LocalStorage()


    func setSpeakerOnOff(isOn:Bool) {
        UserDefaults.standard.set(isOn, forKey:KEY.SPEAKER_ON_OFF)
    }

    func getIsSpeakerOnOff() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY.SPEAKER_ON_OFF)
    }


    func setEntryHeaderIndex(headerListIndex:[String]) {
        UserDefaults.standard.set(headerListIndex, forKey: KEY.ENTRY_HEADER_INDEX)
    }
    
    func getEntryHeaderIndex() -> [String] {
        
        return UserDefaults.standard.stringArray(forKey: KEY.ENTRY_HEADER_INDEX)!
    }
    
    func setTraderMngNum(traderMngNum:String) {
        UserDefaults.standard.set(traderMngNum, forKey:KEY.TRADER_MNG_NUM)
    }
    
    func getTraderMngNum() -> String{
        UserDefaults.standard.string( forKey:KEY.TRADER_MNG_NUM)!
    }
    
    func setUserNum(userNum:String) {
        UserDefaults.standard.set(userNum, forKey:KEY.USER_NUM)
    }
    
    func getUserNum() -> String{
        UserDefaults.standard.string( forKey:KEY.USER_NUM)!
    }
    
    func setUserToken(token:String) {
        UserDefaults.standard.set(token, forKey: KEY.USER_TOKEN)
    }
    func getUserToken() -> String {
        UserDefaults.standard.string(forKey: KEY.USER_TOKEN) ?? ""
    }
 
    func setNetHost(netHost:String) {
        UserDefaults.standard.set(netHost, forKey: KEY.NET_HOST)
    }
    func getNetHost() -> String {
        UserDefaults.standard.string(forKey: KEY.NET_HOST)!
    }
    
    func setNetPort(netPort:String) {
        UserDefaults.standard.set(netPort, forKey: KEY.NET_PORT)
    }
    func getNetPort() -> String {
        UserDefaults.standard.string(forKey: KEY.NET_PORT)!
    }
    
    func setNearestBranch(nearestBranch:String) {
        UserDefaults.standard.set(nearestBranch, forKey: KEY.NEAREST_BRANCH)
    }
    func getNearestBranch() -> String {
        UserDefaults.standard.string(forKey: KEY.NEAREST_BRANCH)!
    }
    
    func setNaBzPlc(naBzPlc : String ) {
        UserDefaults.standard.set(naBzPlc, forKey: KEY.NA_BZ_PLC)
    }
    func getNaBzPlc() -> String {
        UserDefaults.standard.string(forKey: KEY.NA_BZ_PLC)!
    }
    
    func setAgoraAppId(agoraAppId: String) {
        UserDefaults.standard.set(agoraAppId, forKey: KEY.AGORA_APP_ID)
    }
    
    func getAgoraAppId() -> String {
        UserDefaults.standard.string(forKey: KEY.AGORA_APP_ID)!
    }
    
    func setIsSameNearest(isSameNearest:Bool) {
        UserDefaults.standard.set(isSameNearest, forKey: KEY.IS_SAME_NEAREST)
    }
    func getIsSameNearest() -> Bool {
        UserDefaults.standard.bool(forKey: KEY.IS_SAME_NEAREST)
    }
    
    func setIsBackground(isBackground:Bool) {
        UserDefaults.standard.set(isBackground, forKey: KEY.IS_BACKGROUND)
    }
    func getIsBackground() -> Bool {
        UserDefaults.standard.bool(forKey: KEY.IS_BACKGROUND)
    }
    
    func setIsAgreePermission(isAgreePermission:Bool) {
        UserDefaults.standard.set(isAgreePermission, forKey: KEY.IS_AGREE_PERMISSION)
    }
    func getIsAgreePermission() -> Bool {
        UserDefaults.standard.bool(forKey: KEY.IS_AGREE_PERMISSION)
    }
    
    func setIsBatchSelection(isBatchSelection:Bool) {
        UserDefaults.standard.set(isBatchSelection, forKey: KEY.IS_BATCH_SELECTION)
    }
    func getIsBatchSelection()->Bool{
        UserDefaults.standard.bool(forKey: KEY.IS_BATCH_SELECTION)
    }
    
    func setIsDynamicLinks(isDynamicLinks:String) {
        UserDefaults.standard.set(isDynamicLinks, forKey: KEY.IS_DYNAMICLINKS)
    }
    func getIsDynamicLinks() ->String{
        UserDefaults.standard.string( forKey: KEY.IS_DYNAMICLINKS) ?? ""
    }
    
    func resetAll(){
        setUserToken(token: "")
        setNaBzPlc(naBzPlc: "")
    }
}
