//
// Created by Sunyoung Choi on 2021/08/27.
//

import Foundation
import UIKit

/***
 소켓 공통 변수
 */
struct SOCKET_COMMON {
    static let DELIMITER = "|"
    static let REQUEST_CONNECTION_CHANNEL = 6001
    static let REQUEST_CONNECTION_OBSERVERMODE_CHANNEL = 6003
    static let CONNECTION_CHANNEL_NAME = "IOS"
    static let TERMINATOR = "\r\n"
}

/**
 소켓 프로토콜의 공통 코드명 약어
 */
struct SOCKET_PROTOCOL_CODE {
    static let CONNECTION_INFO = "AI"
    static let AUCTION_CHECK_SESSION = "SS"
    static let AUCTION_RESPONSE_SESSION = "AA"
    static let RESPONSE_CONNECTION_INFO = "AR"
    static let AUCTION_BID_STATUS = "AY"
    static let TOAST_MESSAGE = "ST"
    static let AUCTION_STATE = "AS"
    static let SHOW_ENTRY_INFO = "SH"
    static let AUCTION_RESULT = "AF"
    static let CURRENT_ENTRY_INFO = "SC"
    static let BIDDING = "AB"
    static let CANCEL_BIDDiNG = "AC"
    static let REQUEST_ENTRY_INFO = "AE"
    static let REQUEST_BIDDING_INFO = "AD"
    static let RESPONSE_BIDDING_INFO = "AP"
    static let RETRY_TARGET_INFO = "AN"
    static let RESPONSE_CODE = "SE"
    static let AUCTION_COUNT_DOWN = "SD"
    static let AUCTION_TYPE="AT"
}

/**
 소켓 프로토콜의 연결상태 코드 ( 사용안함 )
 */
struct SOCKET_CONNECTION_CODE {
    static let SUCC = 2000
    static let FAIL = 2001
    static let DUPLICATE = 2002
    static let BEFORE_AUCTION = 2003
}

/***
 경매화면의 이미지TAG를 통한 콘트롤 위한 코드
 */
struct VIEW_TAG {
    static let SUB_VIEW_TAG_BASE = 190001
    static let REMOTE_VIEW_TAG_BASE = 200001
    static let READY_CAST_TAG_BASE = 210001
}

/***
 소켓상태 코드값
 */
struct SOCKET_STATUS {
    static let DISCONNECTED = "DISCONNECTED"
    static let CONNECTED = "CONNECTED"
    static let DISCONNECT_FOR_BACK = "DISCONNECT_FOR_BACK"
}

/***
 소켓의 디버그용 호스트 설정하는 값
 */
struct SOCKET {
//    static let DEBUG_HOST = "10.244.22.20"
//    static let DEBUG_HOST = "192.168.0.34"
}

/**
 웹에서 사용하는 각종 urL및 파라미터 값
 */
struct WEB {
    // 호스트 맨 마지막에 /붙이면 안됨
    static let AGENT = "NHAuctionIOS"
//    static let HOST = "https://www.xn--e20bw05b.kr" //난장 (개발서버)
    static let HOST = "https://www.xn--o39an74b9ldx9g.kr" //가축시장
    //static let HOST = "http://10.244.22.20:18080" //로컬 개발

    static let DEFAULT_URL = "/home"
    static let APP_VERSION = "/api/appversion"
    static let FAVORITE = "/api/%@/my/%@/favorite"
    static let AUCTION_POPUP = "/auction/api/entryListApi?naBzplc=%@&loginNo=%@"
    static let KAKAO_CONNECT_URL = "/api/%@/biz/%@/kakao"
    static let VERSION = "v1"
    static let NEAR_ATDR_AM_URL = "/api/%@/my/select/nearAtdrAm"
    static let DYNAMICLINK_BASE_URL = "https://nhauction.page.link"
    static let DYNAMICLINK_BASE_PARAM = "urlParam="
}

// 스트리밍 서비스의 서비스아이디및 서비스 키
struct STREAMING {
    // MY KEY
//    static let DEBUG_SERVICE_ID = "434fe1c4-ede0-4a8a-8f38-3bab4fc3cd75"
//    static let DEBUG_SERVICE_KEY = "bf6048577d544bc4ee8fc8a088595a2c73d737a82668f9b993ff641926e2760e"

    // ISHIFT KEY
//    static let DEBUG_SERVICE_ID = "37924178-ee14-4f8a-9caa-ff858defea7f"
//    static let DEBUG_SERVICE_KEY = "5f7bc510a5607072e1a648926e7bfe1df6a44dfb800e750a698bf5265469e6ce"
//
    
//    // NEW KEY
//    static let SERVICE_ID = "5df17884-e8cf-4b10-9f9b-2ed6a209e1df"
//    static let SERVICE_KEY = "e2ed251804cb43d2de311e2f9b3389bf754cb09953a340db919b02e5d947ba64"
    
    static let EXCEPT_CHANNEL = ["CH83862f19b9f040b7a295a5e3076fb7d9"]
}

/**
 화면 동작을 위한 구분코드 코드값에 따라 화면표시방법이 달라짐
 */
struct SCREEN_ACTION_TYPE {
    static let TOAST_MESSAGE = "ToastMessage"
    static let TOAST_MESSAGE_BIG = "ToastMessageBig"
    static let STATUS_STRING = "StatusString"
    static let STATUS_TOAST = "StatusToast"
    static let FORCE_BACK_STRING = "ForceBackString"
    static let FORCE_BACK_ATTR = "ForceBackAttr"
    static let ONE_BUTTON = "OneButton"
}

/// StoryBoard - 스토리보드 File Name을 가지고 있는 구조체
struct STORYBOARD {

    /// Main.storyboard 파일 이름
    static let MAIN = "Main"
    static let REALTIME = "Realtime"
    static let POPUP = "Popup"
    
}

struct LABEL_TAG {
    static let GREEN_LABEL = 190000
    static let RED_LABEL = 190010
}
//struct CAST_VIEW_TAG {
//    static let TAG_BASE = 10000
//    static let FIRST_VIEW = 10001
//    static let SECOND_VIEW = 10002
//    static let THIRD_VIEW = 10003
//    static let REMOTE_VIEW = 10099
//}

/// ViewController
struct VIEWCONTROLLER {

    static let WEB = "NHWebViewController"
    static let MAIN = "MainViewController"
    static let REALTIME = "RealtimeViewController"
    static let LAUNCH = "LaunchScreenViewController"
    static let NAVIGATION = "BaseNavigationViewController"
    static let POPUP_ONE_BTN    = "PopupOneBntViewController"
    static let POPUP_TWO_BTN    = "PopupTwoBntViewController"
}

/// ENTRY값에 대한 순서및 기본값 목록
struct ENTRY_HEADER {
    static let LIST = ["번호","출하주","성별","중량","어미","계대","산차","KPN","지역명","비고","최저가","친자"]
    static let DEFAULT = ["번호","성별","출하주","중량","산차","어미","계대","KPN","최저가","비고"]
}
/// Common Color
struct COLOR {
    static let BASE_COLOR_1D2029 = "#1D2029"
    static let BASE_COLOR_ORANGE = "#FD6705"
    static let RGB_000000 = "#000000"
    static let RGB_DBDBDB = "#DBDBDB"
    static let RGB_007EFF = "#007EFF"// dark blue rgb 0 126 255
    static let RGB_E6EFFF = "#E6EFFF"
    static let RGB_76BAFF = "#76BAFF"     // nhcancel
    static let RGB_FBB584       = "#FBB584"
    static let RGB_606267       = "#606267"
    static let RGB_FF6500       = "#FF6500"
    static let RGB_FFFFFF       = "#FFFFFF"
    static let RGB_FD6705       = "#FD6705"
    static let RGB_994F20       = "#994F20"
    static let RGB_676A71       = "#676A71"
    static let RGB_43464B       = "#43464B"
    static let RGB_A8A9AE       = "#A8A9AE"
    static let RGB_54B57F       = "#54B57F"
    static let RGB_6098FF       = "#6098FF"     // 96, 152, 255
    static let RGB_EC3634       = "#EC3634"     // 236, 54, 52
    static let RGB_EB6705       = "#EB6705" // bright orange
    static let RGB_D8D8D8       = "#D8D8D8"     // 216, 216, 216
    static let RGB_44464C = "#44464C" // 68, 70, 76
    static let RGB_CCCCCC   = "#CCCCCC" // 취소의 배경색
    static let RGB_394161 = "#394161" //동영상 배경
    static let ARGB_4CFFFFFF    = "#4CFFFFFF"
    static let ARGB_33FFFFFF    = "#33FFFFFF"
    static let ARGB_66FD6705    = "#66fd6705"
    static let ARGB_0CB1D0FF    = "#0CB1D0FF"
    static let ARGB_99FFFFFF    = "#99FFFFFF"
    static let ARGB_OCB1D0FF    = "#OCB1D0FF"
    static let ARGB_1AE5E5E5    = "#1AE5E5E5" // 229, 229, 229, 10%
    static let ARGB_1AB1D0FF    = "#1AB1D0FF" // 177,208,255 10%
    static let ARGB_0DB1D0FF    = "#0DB1D0FF" // 177, 208, 255, 5%
    static let ARGB_80000000    = "#80000000" // 229, 229, 229, 10%
}

/// Common Font Size
struct FONTSIZE {
    static let PT_16: CGFloat = 16.0
    static let PT_15: CGFloat = 15.0
    static let PT_14: CGFloat = 14.0
    static let PT_13: CGFloat = 13.0
    static let PT_12: CGFloat = 12.0
    static let PT_11: CGFloat = 11.0
    static let PT_9: CGFloat  = 9.0
}

struct CODE_MSG {
    static var CODE = 8000
    static var MSG = "MSG"
}

/// 경매 상태에 대한 enum (현재 사용안함)
enum AUCTION_STATE{
    case UNKNOWN
    case NONE
    case READY
    case START
    case PROGRESS
    case HOLD
    case COMPLETED
    case FINISH
    case COUNT_DOWN
    case SUCCESS_BID
    case OTHER_SUCCESS_BID
    case PENDING_BID
    case RETRY_BID
    case RETRY_NOT_BID
    case BATCH_SELECTION
    case BATCH_BIDDING
    
    func msg() -> String{
        switch self {
        case .UNKNOWN:
                return "UNKNOWN"
        case .NONE:
            return "금일 경매 X"
        case .READY:
            return "금일 경매 대기"
        case .START:
            return "현 출품 정보 경매 시작"
        case .PROGRESS:
            return "현 출품 정보 경매 진행"
        case .HOLD:
            return "현 출품 경매 보류"
        case .COMPLETED:
            return "현 경매 완료"
        case .FINISH:
            return "금일 경매 종료"
        case .COUNT_DOWN:
            return "경매 종료 카운트 다운"
        case .SUCCESS_BID:
            return "낙찰"
        case .OTHER_SUCCESS_BID:
            return "타인 낙찰"
        case .PENDING_BID:
            return "낙찰 보류"
        case .RETRY_BID:
            return "재경매"
        case .RETRY_NOT_BID:
            return "재경매 미대상"
        case .BATCH_SELECTION:
            return "일괄 경매 번호 입력"
        case .BATCH_BIDDING:
            return "일괄 경매 응찰 금액 입력"
        }
    }
    
    func code() -> Int{
        switch self {
        case .UNKNOWN:
            return 168000
        case .NONE:
            return 168001
        case .READY:
            return 168002
        case .START:
            return 168003
        case .PROGRESS:
            return 168004
        case .HOLD:
            return 168005
        case .COMPLETED:
            return 168006
        case .FINISH:
            return 8007
        case .COUNT_DOWN:
            return 8101
        case .SUCCESS_BID:
            return 258001
        case .OTHER_SUCCESS_BID:
            return 258002
        case .PENDING_BID:
            return 258003
        case .RETRY_BID:
            return 8104
        case .RETRY_NOT_BID:
            return 8105
        case .BATCH_SELECTION:
            return 8106
        case .BATCH_BIDDING:
            return 8107
        
        }
    }
}

struct BIDDING_RESULT {
    let SUCCESS = "SUCCESS"
    let HOLD = "HOLD"
    let CANCEL = "CANCEL"
}

struct CAST_STATE {
    let STOP = "STOP"
    let JOIN = "JOIN"
    let PLAYING = "PLAYING"
}

struct LOADING_DIALOG_STATE {
    let NONE = "NONE"
    let SHOW = "SHOW"
    let DISMISS = "DISMISS"
}

struct TEXT {
    // Common
    static let NOTICE = "알림"
    static let CONFIRM = "확인"
    static let CANCEL = "취소"
    static let CLOSE = "닫기"
    static let AGREE = "동의"
    static let NOT_AGREE = "동의안함"
    static let UPDATE = "업데이트"
}


struct FONT {
    // Common Font
    static let APP_MEDIUM = "NotoSansCJKKR-Medium"
    static let APP_BOLD = "NotoSansCJKKR-Bold"
}
