//
// Created by Sunyoung Choi on 2021/08/27.
//

import UIKit
import SystemConfiguration
import JWTDecode
import AVFAudio

func debug(_ message: String..., separator: String = "") {
    #if DEBUG
    if separator == "" {
        Swift.print(message)
    } else {
        Swift.print(message, separator: separator)
    }
    #endif
}

/***
 디버그용 프린트
 - Parameter items: 로그남길 목록
 */
func debugPrint(_ items: Any...) {
    #if DEBUG
    Swift.debugPrint(getTodayDate(format: "yyyy/MM/dd HH:mm:ss.SSS"),items)

    #endif
}

/**
 현재 appVersion을 반환
 */
func currentAppVersion() -> String {
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    return currentVersion
}
// Check Network
func connectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)

    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }

    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }

    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)

    return (isReachable && !needsConnection)
}

func getTodayDate(format: String? = "yy.MM.dd")->String{
    let df = DateFormatter()
    df.dateFormat = format
    return df.string(from: Date())
}



// Go App Store
func goAppStore() {
    debugPrint(">> goAppStore")
    if let url = URL(string: "itms-apps://itunes.apple.com/app/1588847718"),
 UIApplication.shared.canOpenURL(url) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}


/***
 오디오 레벨조정하는 Method
 - Parameter enabled:
 */
func setAudioOutputSpeaker(enabled: Bool)
{
    let session = AVAudioSession.sharedInstance()

    var _: Error?
    try? session.setCategory(AVAudioSession.Category.playAndRecord)
    try? session.setMode(AVAudioSession.Mode.voiceChat)
    if enabled {
        try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
    } else {
        try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
    }
    try? session.setActive(enabled)
}


/***
 Socket 파싱용 함수
 - Returns:
 */
func connectionInfo(isObserverMode: Bool, _ token: String?)-> String{
    
    var tokenString =  LocalStorage.shared.getUserToken()
    if isObserverMode {
        tokenString = token ?? ""
    }
    var result = "";
    do {
        let jwt = try decode(jwt: tokenString)
        let connectionInfo : ConnectionInfo = ConnectionInfo()
        connectionInfo.type = SOCKET_PROTOCOL_CODE.CONNECTION_INFO
        connectionInfo.auctionHouseCode = jwt.auctionHouseCode!
        connectionInfo.traderMngNum = jwt.userMemNum!
        connectionInfo.token = tokenString
        if isObserverMode {
            connectionInfo.channel = SOCKET_COMMON.REQUEST_CONNECTION_OBSERVERMODE_CHANNEL // 관전모드
        }else{
            connectionInfo.channel = SOCKET_COMMON.REQUEST_CONNECTION_CHANNEL // 경매참여
        }
        
        connectionInfo.osType = SOCKET_COMMON.CONNECTION_CHANNEL_NAME
        
        result = connectionInfo.toString()
    }catch{
        
    }
    return result
}

/***
 Socket 파싱용 함수 [CurrentEntryInfo]
 - Returns:
 */
func actCurrentEntryInfo(currentEntryInfo:CurrentEntryInfo) -> (Bool, [String]) {
    var returnVal : (Bool,[String]) = (false,[])
    var returnDataList : [String] = []
//    var valueDic : [String:String]  = [:]
    
    let headerList = LocalStorage.shared.getEntryHeaderIndex()

    
//    1. 출품번호
//    2. 출하주
//    3. 성별
//    4. 중량
//    5. 어미
//    6. 계대
//    7. 산차
//    8. KPN
//    9. 지역명
//    10. 비고
//    11. 최처가
//    12. 친자여부
    
    
    
    for elem in headerList {

        switch elem {
            case "1":
            returnDataList.append(currentEntryInfo.entryNum)
                break
            case "2":
            returnDataList.append(currentEntryInfo.exhibitor)
                break
            case "3":
            returnDataList.append(currentEntryInfo.entryGender)
                break
            case "4":
            returnDataList.append(currentEntryInfo.weight)
                break
            case "5":
            returnDataList.append(currentEntryInfo.motherTypeCode)
                break
            case "6":
            returnDataList.append(currentEntryInfo.pasgQcn)
                break
            case "7":
            returnDataList.append(String(currentEntryInfo.cavingNum))
                break
            case "8":
            returnDataList.append(currentEntryInfo.entryKpn)
                break
            case "9":
            returnDataList.append(currentEntryInfo.productionArea)
                break
            case "10":
            returnDataList.append(currentEntryInfo.note)
                break
            case "11":
            returnDataList.append(String(currentEntryInfo.lowPrice))
                break
            case "12":
            returnDataList.append(currentEntryInfo.isPaternalExamination)
                break

        default:
            break
        }
    }
    returnVal.1 = returnDataList
    returnVal.0 = true
    return returnVal

}


func actEntryText(position:Int) ->String {
    let result :String
    let entryHeaderList = ENTRY_HEADER.LIST
    
    guard entryHeaderList.indices.contains(position) else {
        return ""
    }
    result = entryHeaderList[position]
    
    return result
}

/***
 touch시 impact를 주는 method
 but 기기및 설정에 따라 동작 안할수 있음
 */
func impact() {
    
    if #available(iOS 13.0, *) {
        let generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
        generator.impactOccurred()
    } else {
        // Fallback on earlier versions
        let generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.heavy)
        generator.impactOccurred()
    }
    
}

/***
 Socket Receive시 화면처리 공통 함수
 statusCode의 앞 2자리는 프로토콜정의서에 있는순서
 statusCode의 뒤 4자리는 각 프로토콜별 정상메세지코드및 에러메세지 그리고 기타 메세지코드
 - Returns:
 */
func screenAction(statusCode:Int, message:String...) -> ScreenAction {
    let result :ScreenAction = ScreenAction()
    switch statusCode {

    case 120001:
        result.attributedString = STATUS_VIEW.init(string: "응찰 금액을 입력하세요.", blueStart: 0, blueLength: 5)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
        
    case 142000:
        result.attributedString = STATUS_VIEW.init(string: "경매 대기 중입니다.", blueStart: 3, blueLength: 4)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
        
    case 142001:
        result.forceBackString = "경매를 참여하실 수 없습니다. \n 경매 참여를 원하실 경우 관리자에게 문의하세요."
        result.type = SCREEN_ACTION_TYPE.FORCE_BACK_STRING
        
    case 142002:
        result.forceBackString = "이미 접속한 사용자가 있습니다."
        result.type = SCREEN_ACTION_TYPE.FORCE_BACK_STRING
        
    case 142003, 142004, 142005:
        result.forceBackString = "현재 참여 가능한 경매가 없습니다.\n 관리자에게 문의하세요."
        result.type = SCREEN_ACTION_TYPE.FORCE_BACK_STRING
    
    case 150000:
        result.attributedString = STATUS_VIEW.init(string: "응찰되었습니다.", blueStart: 0, blueLength: 2)!.attrString
        result.toastMessageBig = "응찰되었습니다"
        result.type = SCREEN_ACTION_TYPE.TOAST_MESSAGE_BIG
        
    case 150001:
        result.statusToast = STATUS_VIEW.init(string: "금액을 입력해 주세요.", blueStart: 0, blueLength: 0)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
        
    case 150002:
        let msgString = "응찰금액을 확인 하세요."
        result.statusToast = STATUS_VIEW.init(string: msgString, redStart: 0, redLength: msgString.count)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
        
    case 150003:
        result.statusToast = STATUS_VIEW.init(string: "현재 응찰 가능상태가 아닙니다.", blueStart: 0, blueLength: 0)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST

    case 150010:
        result.statusToast = STATUS_VIEW.init(string: "재경매 대상이 아닙니다.", blueStart: 0, blueLength: 0)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
        
    case 168001:
        result.forceBackString = "진행중인 경매가 없습니다."
        result.type = SCREEN_ACTION_TYPE.FORCE_BACK_STRING
        
        // 팝업으로 띄운후 빠지기
        
    case 168002: //AUCTION_STATE.READY.code():
        result.attributedString = STATUS_VIEW.init(string: "경매 대기 중입니다.", blueStart: 3, blueLength: 4)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
        
    case 168003: //AUCTION_STATE.START.code():
        result.attributedString = STATUS_VIEW.init(string: "응찰하시기 바랍니다.", blueStart: 0, blueLength: 2)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
        
    case 168004: //AUCTION_STATE.PROGRESS.code():
        result.attributedString = STATUS_VIEW.init(string: "응찰하시기 바랍니다.", blueStart: 0, blueLength: 2)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
        
    case 168104: //AUCTION_STATE.PROGRESS.code():
        // 일괄경매의 168004 일때
        result.attributedString = STATUS_VIEW.init(string: "경매 번호를 입력하세요.", blueStart: 0, blueLength: 5)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
//        case 168005:
        
    case 168006: //AUCTION_STATE.COMPLETED.code():
        result.attributedString = STATUS_VIEW.init(string: "경매 대기 중입니다.", blueStart: 3, blueLength: 4)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
        
    case 168007: //AUCTION_STATE.FINISH.code():
        
        let attributedString = STATUS_VIEW.init(string: "경매 종료되었습니다.", blueStart: 0, blueLength: 5)!.attrString
        
        result.attributedString = attributedString
        result.type = SCREEN_ACTION_TYPE.FORCE_BACK_ATTR

    case 168008: //AUCTION_STATE.COMPLETED.code():
        result.attributedString = STATUS_VIEW.init(string: "경매가 종료되었습니다.", redStart: 4, redLength: 2)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
    
    case 180000: //AUCTION_STATE.COUNT_DOWN.code():
        switch message[0] {
        case "R":
            result.attributedString = STATUS_VIEW.init(string: "경매 대기 중입니다.", blueStart: 3, blueLength: 4)!.attrString
            result.type = SCREEN_ACTION_TYPE.STATUS_STRING
        case "C":
            result.attributedString = STATUS_VIEW.init(string: "응찰 마감 \(message[1])초 전", redStart: 6, redLength: 4)!.attrString
            result.type = SCREEN_ACTION_TYPE.STATUS_STRING
        case "F":
//            result.attributedString = STATUS_VIEW.init(string: "응찰하시기 바랍니다.", blueStart: 0, blueLength: 2)!.attrString
//            result.type = SCREEN_ACTION_TYPE.STATUS_STRING
            break
        default:
            break
        }
    case 190000:
        result.toastMessage = message[0]
        result.type = SCREEN_ACTION_TYPE.TOAST_MESSAGE
    case 201001: //AUCTION_STATE.COMPLETED.code():
        result.attributedString = STATUS_VIEW.init(string: "경매 번호를 입력하세요.", blueStart: 0, blueLength: 5)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
    case 204001:
        result.oneButtonString = "출장우 정보가 없습니다.\n경매 번호를 확인해주세요."
        result.type = SCREEN_ACTION_TYPE.ONE_BUTTON
        break
    case 204002:
        result.statusToast = STATUS_VIEW.init(string: "현재 응찰가능한 상태가 아닙니다.", redStart: 0, redLength: 0)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
        break
    case 204003:
        result.statusToast = STATUS_VIEW.init(string: "응찰금액을 확인 하세요.", redStart: 0, redLength: "응찰금액을 확인 하세요.".count)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
        break
    case 204004:
        result.forceBackString = "진행중인 경매가 없습니다."
        result.type = SCREEN_ACTION_TYPE.FORCE_BACK_STRING
        break
    case 204005:
        result.statusToast = STATUS_VIEW.init(string: "현재 취소 가능상태가 아닙니다.", blueStart: 0, blueLength: 0)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
        break

    case 204006:
        result.attributedString = STATUS_VIEW.init(string: "응찰되었습니다", blueStart: 0, blueLength: 2)!.attrString
        result.toastMessageBig = "응찰되었습니다"
        result.type = SCREEN_ACTION_TYPE.TOAST_MESSAGE_BIG
        break
    case 204007:
        result.statusToast = STATUS_VIEW.init(string: "응찰 취소 되었습니다.", blueStart: 0, blueLength: 5)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
        break
    case 250011:
        break
    case 250022:
        
        var unitTypeValue = "만 원"
        if message.count == 3 {
            unitTypeValue = message[2]
        }
        
        let userNum = LocalStorage.shared.getUserNum()
        if(message[0] == userNum) {
            //AUCTION_STATE.SUCCESS_BID.code()
            let resultPrice = Int(message[1])!
            let msgString = "\(resultPrice.withCommas())\(unitTypeValue) 낙찰"
            
                    
            let range: Range<String.Index> = msgString.range(of: "낙찰")!
            let position : Int = msgString.distance(from: msgString.startIndex, to: range.lowerBound)
           
            result.attributedString = STATUS_VIEW.init(string: msgString, blueStart: position, blueLength: 2)!.attrString
        } else {
            
            let resultPrice = Int(message[1])!
            
            let msgString = "낙찰금액 \(resultPrice.withCommas())\(unitTypeValue) / \(message[0])번"
            result.attributedString = STATUS_VIEW.init(string: msgString, blueStart: 0, blueLength: msgString.count)!.attrString
        }
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
    case 250023:
        //AUCTION_STATE.PENDING_BID.code():
        result.attributedString = STATUS_VIEW.init(string: "유찰되었습니다.", blueStart: 0, blueLength: 2)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
        break
    case 250024:
        //AUCTION_STATE.PENDING_BID.code():
        result.statusToast = STATUS_VIEW.init(string: "경매 대기중입니다.", blueStart: 3, blueLength: 3)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
    case 260000:
        result.statusToast = STATUS_VIEW.init(string: "응찰 취소되었습니다.", blueStart: 0, blueLength: 5)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
    case 260001:
        result.attributedString = STATUS_VIEW.init(string: "응찰 하시기 바랍니다.", blueStart: 0, blueLength: 2)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
    case 261001:
        result.statusToast = STATUS_VIEW.init(string: "응찰 취소를 할수 없습니다.", blueStart: 0, blueLength: 0)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
    case 261002:
        result.statusToast = STATUS_VIEW.init(string: "응찰 취소를 할수 없습니다.", blueStart: 0, blueLength: 0)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
    case 261003:
        result.statusToast = STATUS_VIEW.init(string: "응찰 취소를 할수 없습니다.", blueStart: 0, blueLength: 0)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
        // 일괄경매일때 취소버튼 눌렀을때
    case 263001:
        //응찰취소되었습니다.
//        statusToast
//        result.attributedString = STATUS_VIEW.init(string: "응찰 하시기 바랍니다.", blueStart: 0, blueLength: 2)!.attrString
//        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
//
        result.attributedString = STATUS_VIEW.init(string: "경매 번호를 입력하세요.", blueStart: 0, blueLength: 5)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING

    // 일괄 0 entry입력시
    case 300001:
        result.statusToast = STATUS_VIEW.init(string: "경매 번호를 입력해주세요.", blueStart: 0, blueLength: 0)!.attrString
        result.type = SCREEN_ACTION_TYPE.STATUS_TOAST
    case 320000:
        let bidders = message[0].split(separator: ",")
        var inMember = false
        let userNum = LocalStorage.shared.getUserNum()
        for (_, elem) in bidders.enumerated() {
            if elem == userNum {
                inMember = true
            }
        }
        
        if inMember == true {
            result.attributedString = STATUS_VIEW.init(string: "재응찰하시기 바랍니다.", blueStart: 0, blueLength: 3)!.attrString
            result.type = SCREEN_ACTION_TYPE.STATUS_STRING
            result.extraBool = true
        } else {
            result.attributedString = STATUS_VIEW.init(string: "재경매 진행 중입니다.", blueStart: 0, blueLength: 3)!.attrString
            result.type = SCREEN_ACTION_TYPE.STATUS_STRING
            result.extraBool = false
        }
        
    case 360000:
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING

        if message[0] == "F" {
            result.attributedString = STATUS_VIEW.init(string: "응찰 종료되었습니다.", blueStart: 0, blueLength: 2)!.attrString
        }
        if message[0] == "P" {
            result.attributedString = STATUS_VIEW.init(string: "응찰 하시기 바랍니다.", blueStart: 0, blueLength: 2)!.attrString
        }
        
        result.type = SCREEN_ACTION_TYPE.STATUS_STRING
    default:
        break
    }
    return result
}

func checkSecTrustEvalute(trustInput: SecTrust, trustResultType: UnsafeMutablePointer<SecTrustResultType>) {
    if #available(iOS 13.0, *) {
        var error: CFError?
        let evaluationSucceeded = SecTrustEvaluateWithError(trustInput, &error)
        
        if !evaluationSucceeded {
            debugPrint("Evaluation Failed")
        }
    } else {
        let error: OSStatus = SecTrustEvaluate(trustInput, trustResultType)

        if (error != noErr) {
            debugPrint("Evaluation Failed")
        }
    }
}
