//
//  WebViewController.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/01.
//

import UIKit
import WebKit
import JWTDecode
import ObjectMapper
import SwiftyJSON

/***
 웹뷰동작용 ViewConroller
 */
class NHWebViewController: BaseWebViewController, UINavigationControllerDelegate, WKUIDelegate, StreamDelegate,WKNavigationDelegate {
    
    @IBOutlet weak var baseView1: UIView!
    @IBOutlet var viewBase: UIView!
    
    public enum Exception: Error {
        case streamInitFailure
        case unreadyToWrite
        case unableToSetupReadTLS
        case unableToSetupWriteTLS
    }
    
    var popupWebView: WKWebView?
    var status = SOCKET_STATUS.DISCONNECTED
    // Input and output streams for socket
    var inputStream: InputStream?
    var outputStream: OutputStream?
    // Secondary delegate reference to prevent ARC deallocating the NSStreamDelegate
    var inputDelegate: StreamDelegate?
    var outputDelegate: StreamDelegate?
    var currentAuctionCodeName : String = ""
    // 관전 여부
    var clickObserverMode = false // 관전모드 유/무 flag
    var observerModeToken: String?
    var observerModeURL: String?
    ///웹뷰 경매관전버튼 중복호출 방지
    var ischeckAuctionWatch: Bool = false
    ///웹뷰 경매응창버튼 중복호출 방지
    var ischeckAuctionBid: Bool = false
    ///경매입장불가알림창체크
    var isCanNotEnterAuctionAlert: Bool = false
    var nhWebView: BaseWKWebView!
    var externUrl: String = ""
    var firstDynamicLinks: String = ""
    var dynamicLinks: String = "" {
        willSet {
            debugPrint("### NHWebViewController dynamicLinks willSet'newValue : \(newValue)")
            if (newValue.contains(WEB.DYNAMICLINK_BASE_PARAM)) {
                
                let arr = newValue.components(separatedBy: WEB.DYNAMICLINK_BASE_PARAM);
                let realLink = arr[1]
                debugPrint("### realLink : \(realLink)")
                self.loadDynamicLink(url: realLink)
                
            } else {
                debugPrint("### willset https://nhauction.page.link 도 urlParam=도 아닌 경우")
                if (newValue.contains("https://www.xn--o39an74b9ldx9g.kr")) {
                    debugPrint("### willset https://nhauction.page.link 도 urlParam=도 아닌 경우로 들어옴")
                    self.loadDynamicLink(url: newValue)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.firstDynamicLinkLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //뷰가 사라졌을때 웹뷰의 경매관전 혹은 경매응찰 버튼 초기화
        if (self.ischeckAuctionBid == true && self.ischeckAuctionWatch == false || self.ischeckAuctionBid == false && self.ischeckAuctionWatch == true) {
            if (self.ischeckAuctionBid == true && self.ischeckAuctionWatch == false) {
                self.ischeckAuctionBid.toggle()
            } else {
                self.ischeckAuctionWatch.toggle()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint("loaded")
        guard let urlString = self.nhWebView.url?.absoluteString else {return}
        /**
         앱 버전 체크 조건
         1. not running  상태에서 앱을 구동하고 홈 화면으로 들어올 경우
         2. not running 상태에서 앱을 구동하고 다이나믹링크를 타고 들어올 경우 
         */
        let currentUrl: String = urlString
        if Singleton.shared.isAppVersionCheck && currentUrl.contains(WEB.DEFAULT_URL) {
            Singleton.shared.isAppVersionCheck.toggle()
            self.nativeToJsForAppVersionSend()
        } else if Singleton.shared.isAppVersionCheck && Singleton.shared.isNotRunningDynamicLink != "" {
            Singleton.shared.isAppVersionCheck.toggle()
            self.nativeToJsForAppVersionSend()
        } else {
            //..
        }
        self.removeSpinner()
    }
    
    //23.02.13 native -> js  appversion 넘기기 테스트
    func nativeToJsForAppVersionSend() {
        /**
         웹단 코드
         window.nativeInterface= {
             getAppVersionInfo : function(appVersion){
                 alert(appVersion);
                 console.log(appVersion);
                 return appVersion;
             }
         }
         */
        let runScript = "window.nativeInterface.getAppVersionInfo('\(currentAppVersion())')"
        print("####  runScript: \(runScript)")
        self.nhWebView.evaluateJavaScript(runScript) { (result, error) in
            print("#### nativeToJsForAppVersionSend error: \(String(describing: error))")
         }
    }
    
    func firstDynamicLinkLoad() {
        //다이나믹링크
        //self.firstDynamicLinks = LocalStorage.shared.getIsDynamicLinks()
        self.firstDynamicLinks = Singleton.shared.isNotRunningDynamicLink
        debugPrint("#### setUpView self.firstDynamicLinks : \(self.firstDynamicLinks)")
        
        //길거나 짧은 동적url로 올경우
        if (self.firstDynamicLinks.contains(WEB.DYNAMICLINK_BASE_PARAM)) {
            let arr = self.firstDynamicLinks.components(separatedBy: WEB.DYNAMICLINK_BASE_PARAM)
            // 딥링크 유효성체크
            if let realLink = arr[safe: 1] {
                self.loadDynamicLink(url: realLink)
            }
        } else {
            // https://nhauction.page.link/link 식의 url로 올경우
            if (self.firstDynamicLinks.contains("https://www.xn--o39an74b9ldx9g.kr")) {
                self.loadDynamicLink(url: self.firstDynamicLinks)
            }
        }
    }
    
    func loadDynamicLink(url: String) {
        //대체url 치환
        guard let convertUrl = url.removingPercentEncoding else {return}
        //html entity 치환
        guard let htmlEntiryConvertUrl = String(htmlEncodedString: convertUrl) else {return}
        debugPrint("### htmlEntiryConvertUrl : \(htmlEntiryConvertUrl)")
        
        let url = URL.init(string:htmlEntiryConvertUrl)!
        let request = URLRequest.init(url: url);
        self.nhWebView.load(request)
    }
    
    func setUpView(){
        let userController = WKUserContentController()
        userController.add(self, name: "back")
        userController.add(self, name: "moveAuctionBid")
        userController.add(self, name: "moveWebPage")
        userController.add(self, name: "setUserInfo")
        userController.add(self, name: "moveAuctionWatch")
        userController.add(self, name: "moveWebUrl")
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.userContentController = userController;
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        nhWebView = BaseWKWebView.init(frame: .zero , configuration: configuration)
        
        nhWebView.clearsContextBeforeDrawing = true
        nhWebView.isOpaque = false
        nhWebView.backgroundColor = .clear
        nhWebView.uiDelegate = self
        nhWebView.navigationDelegate = self
        nhWebView.allowsLinkPreview = false
        self.baseView1.addSubview(nhWebView)
        self.nhWebView.setAutolayout(withView: self.baseView1)

        guard var url = URL.init(string: WEB.HOST + WEB.DEFAULT_URL) else { return }
        
        if externUrl != "" {
            url = URL.init(string: externUrl)!
        }
        
        var request = URLRequest.init(url: url)
        request.httpShouldHandleCookies = true
        
        self.nhWebView.load(request)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        //23.02.17 출장우 조회 -> 리스트중 개체 번호 클릭시 출장우 상세 페이지로 이동하는데 이때 status bar 겹침 이슈
        //-> view에 addSubView하는것이 아닌 nhwebview로 변경
        //-> 이렇게 했을때 높이가 맞지 않아 높이 변경
        //popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
        popupWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.nhWebView.frame.width, height: self.nhWebView.frame.height), configuration: configuration)
        popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupWebView?.navigationDelegate = self
        popupWebView?.uiDelegate = self
        //view.addSubview(popupWebView!)
        self.nhWebView.addSubview(popupWebView!)
        return popupWebView!
    }

    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        popupWebView = nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default) { (action) in
            completionHandler(false)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            if let text = alert.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // tel link(tel:) 처리
        if navigationAction.request.url?.scheme == "tel" {
            UIApplication.shared.open(navigationAction.request.url!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

extension NHWebViewController: WKScriptMessageHandler {
    
    func changeMarginColor(url:String) {
        
    }
    
    /***
     javascript 실행체크용 controller
     - Parameters:
     - userContentController:
     - message:
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("message.name:\(message.name)");
        debugPrint("message.body:\(message.body)");
        switch message.name {
            //뒤로가기
        case "back":
            let alert = UIAlertController(title: nil, message: "Back 버튼 클릭", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(action)
            
            // 단순 webPage이동
        case "moveWebPage":
            guard let outLink = message.body as? String, let _ = URL(string: outLink) else { return }
            
            let link = URL(string: outLink)!
            var request = URLRequest(url: link)
            request.httpShouldHandleCookies = true
            
            // logout시에는 모든 쿠키를 제거
            if(outLink.contains("/user/logoutProc")){
                debugPrint("logout");
                LocalStorage.shared.resetAll()
                debugPrint("userToken: \(LocalStorage.shared.getUserToken())")
                self.nhWebView.cleanAllCookies()
                self.nhWebView.refreshCookies()
            }
            //23.02.20 홈 최하단 개인정보처리방침 화면 닫히지 않느 이슈 대응 
            //이동되는 load되는 Url을 nhwebview -> popupWebView로 변경
            if outLink.contains("privacy") || outLink.contains("agreement"){
                self.popupWebView?.load(request)
            } else {
                self.nhWebView.load(request)
            }
            debugPrint("#188: \(message.name) \(message.body)")
            self.showSpinner(onView: self.view)
            changeMarginColor(url: outLink)

            /// 경매화면으로 이동
        case "moveAuctionBid":
            self.clickObserverMode = false // 관전모드 아님
            self.observerModeURL = ""
            self.observerModeToken = ""
            
            let userToken = LocalStorage.shared.getUserToken()
            if userToken != "" {
                self.nhWebView.evaluateJavaScript("getLoginUserInfo('\(userToken)');", completionHandler: {(result, error) in
                    if let result = result  {
                        
                        debugPrint("#243:\(result)")  // Javascript 함수 complete()에서 반환한 값을 표시
                        
                        if let userTokenParsed = UserTokenParsed(JSONString: String(describing: result)), userTokenParsed.success {
                            LocalStorage.shared.setNearestBranch(nearestBranch: userTokenParsed.nearestBranch)
                            LocalStorage.shared.setNaBzPlc(naBzPlc: userTokenParsed.auctionCode)
                            if userTokenParsed.auctionCode == userTokenParsed.nearestBranch {
                                LocalStorage.shared.setIsSameNearest(isSameNearest: true)
                            } else {
                                LocalStorage.shared.setIsSameNearest(isSameNearest: false)
                            }
                            self.currentAuctionCodeName = userTokenParsed.auctionCodeName
                            //2023.02.02 웹뷰 중복 호출로 인한 뷰 중복 방어 코드
                            if (self.ischeckAuctionBid == false) {
                                self.ischeckAuctionBid = true;
                                self.checkSocket()
                            } else {
                                //
                            }
                        } else {
                            self.showToastNH(text: "토큰 에러발생")
                            guard let url = URL.init(string: WEB.HOST) else {
                                return
                            }
                            var request = URLRequest.init(url: url)
                            request.httpShouldHandleCookies = true
                            self.nhWebView.load(request)
                        }
                    }
                })
            } else {
                guard let url = URL.init(string: WEB.HOST) else {
                    return
                }
                var request = URLRequest.init(url: url)
                request.httpShouldHandleCookies = true
                self.nhWebView.load(request)
            }
        case "setUserInfo":
            guard let json = message.body as? String else {
                return
            }
            
            let userInfo = UserInfo(JSONString: String(describing: json))
            let userToken = userInfo!.userToken
            let nearestBranch = userInfo!.nearestBranch
            let auctionCode = userInfo!.auctionCode
            do {
                let jwt = try decode(jwt: userToken)
                if jwt.expired {
                    return
                } else {
                    LocalStorage.shared.setUserToken(token: userToken)
                    LocalStorage.shared.setNearestBranch(nearestBranch: nearestBranch)
                    LocalStorage.shared.setNaBzPlc(naBzPlc: auctionCode)
                    
                    if auctionCode == nearestBranch {
                        LocalStorage.shared.setIsSameNearest(isSameNearest: true)
                    } else {
                        LocalStorage.shared.setIsSameNearest(isSameNearest: false)
                    }
                }
            }catch {
                debugPrint("default error catch \(error)")
            }
            break
            // 관전화면으로 이동
        case "moveAuctionWatch":
            // 토큰, url 값 설정
            let messageBody = message.body as? String
            let dict = convertToDictionary(text: messageBody ?? "")
            if let url = dict?["url"] as? String, let token = dict?["watch_token"] as? String {
                self.clickObserverMode = true // 관전모드 맞음
                self.observerModeURL = url
                self.observerModeToken = token
                
                self.nhWebView.evaluateJavaScript("getLoginUserInfo('\(token)');", completionHandler: {(result, error) in
                    if let result = result {
                        debugPrint("#340:\(result)")  // Javascript 함수 complete()에서 반환한 값을 표시
                        if let userTokenParsed = UserTokenParsed(JSONString: String(describing: result)), userTokenParsed.success {
                            LocalStorage.shared.setNearestBranch(nearestBranch: userTokenParsed.nearestBranch)
                            LocalStorage.shared.setNaBzPlc(naBzPlc: userTokenParsed.auctionCode)
                            if userTokenParsed.auctionCode == userTokenParsed.nearestBranch {
                                LocalStorage.shared.setIsSameNearest(isSameNearest: true)
                            } else {
                                LocalStorage.shared.setIsSameNearest(isSameNearest: false)
                            }
                            self.currentAuctionCodeName = "경매관전"
                            //self.checkSocket()
                            //2023.02.02 웹뷰 중복 호출로 인한 뷰 중복 방어 코드
                            if (self.ischeckAuctionWatch == false) {
                                self.ischeckAuctionWatch.toggle()
                                self.checkSocket()
                            } else {
                                //
                            }
                        } else {
                            self.showToastNH(text: "토큰 에러발생")
                            guard let url = URL.init(string: WEB.HOST) else {
                                return
                            }
                            var request = URLRequest.init(url: url)
                            request.httpShouldHandleCookies = true
                            self.nhWebView.load(request)
                        }
                    }
                })
            }
            break
        case "moveWebUrl":
            guard let outLink = message.body as? String, let _url = URL(string: outLink) else { return }
            
            debugPrint(outLink)
            if #available(iOS 10.0, *) {
               UIApplication.shared.open(_url, options: [:])
           } else {
               UIApplication.shared.openURL(_url)
           }
            break
        default:
            debugPrint("#277:\(message.name)")
            break
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /***
     웹에서 경매화면으로 진입하기전 소켓 먼저 체크
     */
    func checkSocket() {
        let sockethost = LocalStorage.shared.getNetHost()
        let socketPort = LocalStorage.shared.getNetPort()
#if DEBUG
        //            sockethost = SOCKET.DEBUG_HOST
#endif
        
        debugPrint("check async")
        self.connect(host: sockethost, port: Int(socketPort)!)
        status = SOCKET_STATUS.DISCONNECTED
    }
    
    /***
     소켓에 접속하는 method
     - Parameters:
     - host: 호스트
     - port: 포트
     */
    func connect(host: String, port: Int) {
        let _ = Stream.getStreamsToHost(withName:host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        inputStream!.delegate = self
        outputStream!.delegate = self
        debugPrint("check Stream \(String(describing: self.inputStream))")
        debugPrint("check Stream \(String(describing: self.outputStream))")
        inputStream!.schedule(in: RunLoop.main, forMode: RunLoop.Mode.default)
        outputStream!.schedule(in: RunLoop.main, forMode: RunLoop.Mode.default)
        
        inputStream!.setProperty(kCFStreamSocketSecurityLevelNegotiatedSSL, forKey:  Stream.PropertyKey.socketSecurityLevelKey)
        outputStream!.setProperty(kCFStreamSocketSecurityLevelNegotiatedSSL, forKey: Stream.PropertyKey.socketSecurityLevelKey)
        
        let sslSettings : [NSString: Any] = [
            NSString(format: kCFStreamSSLLevel):kCFStreamSocketSecurityLevelNegotiatedSSL,
            NSString(format: kCFStreamSSLValidatesCertificateChain): kCFBooleanFalse!,
            NSString(format: kCFStreamSSLPeerName): kCFNull!,
            NSString(format: kCFStreamSSLIsServer): kCFBooleanFalse!
        ]
        
        inputStream!.setProperty(sslSettings, forKey:  kCFStreamPropertySSLSettings as Stream.PropertyKey)
        outputStream!.setProperty(sslSettings, forKey: kCFStreamPropertySSLSettings as Stream.PropertyKey)
        
        inputStream!.open()
        outputStream!.open()
    }
    
    /***
     소켓으로 데이터 전송  high level
     - Parameter bytes:
     - Returns:
     - Throws:
     */
    public func send(_ bytes: [UInt8]) throws -> Int {
        guard ((outputStream?.hasSpaceAvailable) != nil) else {
            throw Exception.unreadyToWrite
        }
        return outputStream!.write(UnsafePointer(bytes), maxLength: bytes.count)
    }
    
    /***
     소켓으로 데이터 전송 low level
     - Parameter elements:
     */
    public func write(_ elements: String...) {
        let concated = elements.joined(separator: SOCKET_COMMON.DELIMITER)
        do {
            try _ = self.write(concated)
        } catch {
            debugPrint(error)
        }
    }
    
    public func write(_ string: String = "") throws -> Int {
        debugPrint("SEND \(string)")
        let bytes:[UInt8] = string.utf8.map { $0 }
        return try self.send(bytes)
    }
    
    /***
     데이터 수신에 대한 처리용
     - Parameters:
     - aStream:
     - eventCode:
     */
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.endEncountered:
            //             socketDisconnected()
            break
        case Stream.Event.openCompleted:
            debugPrint("Open Completed")
            break
        case Stream.Event.hasSpaceAvailable:
            //             debugPrint("Has Space Available")
            
            // If you try and obtain the trust object (aka kCFStreamPropertySSLPeerTrust) before the stream is available for writing I found that the oject is always nil!
            let sslTrustInput: SecTrust? =  inputStream! .property(forKey:kCFStreamPropertySSLPeerTrust as Stream.PropertyKey) as! SecTrust?
            let sslTrustOutput: SecTrust? = outputStream!.property(forKey:kCFStreamPropertySSLPeerTrust as Stream.PropertyKey) as! SecTrust?
            
            if sslTrustInput == nil {
                debugPrint("INPUT TRUST NIL")
            } else {
                //                 debugPrint("INPUT TRUST NOT NIL")
            }
            
            if sslTrustOutput == nil {
                debugPrint("OUTPUT TRUST NIL")
            } else {
                //                 debugPrint("OUTPUT TRUST NOT NIL")
            }
            var result: SecTrustResultType = SecTrustResultType.unspecified
            
            checkSecTrustEvalute(trustInput: sslTrustInput!, trustResultType: &result)
            
            if (result != SecTrustResultType.proceed && result != SecTrustResultType.unspecified) {
                debugPrint("Peer is not trusted :(")
            } else {
                if status == SOCKET_STATUS.DISCONNECTED {
                    do {
                        try _ = self.write(connectionInfo(isObserverMode: self.clickObserverMode, self.observerModeToken))
                    } catch {
                        debugPrint(error)
                    }
                    status = SOCKET_STATUS.CONNECTED
                }
            }
            break
        case Stream.Event.hasBytesAvailable:
            var buffer = [UInt8](repeating: 0, count: 2048)
            let bytesRead = inputStream?.read(&buffer, maxLength: buffer.count)
//            23.03.17 경매진행프로그램 실행 -> 종료 -> 실행시 iOS APP 죽는 이슈
//            if bytesRead != nil {
//                let str: String! = String(cString: buffer)
//                parseReceive(transactions: str)
//            } else {
//                debugPrint("Receive String is nil")
//            }
//
//            break
//            RealtimeViewController와 동일하게 코드변경
            guard let bytesRead = bytesRead, bytesRead > 0 else {
                debugPrint("Receive String is nil")
                break
            }
            let data = Data(bytes: buffer, count: bytesRead)
            if let str = String(data: data, encoding: .utf8) {
                parseReceive(transactions: str)
            } else {
                debugPrint("str is nil")
            }
            break
        case Stream.Event.errorOccurred:
            //             debugPrint("Error Occured")
            //             socketDisconnected()
            break
        default:
            debugPrint("Default")
            break
        }
    }
    
    /***
     수신데이터 파싱용
     - Parameter transactions: 수신 데이터 Text
     */
    func parseReceive(transactions :String){
        // TERMINATOR를 이용하여 다중 패킷 split
        let transactionArr = transactions.components(separatedBy: SOCKET_COMMON.TERMINATOR)
        for transaction in transactionArr {
            if(transaction.count>1) {
                debugPrint("RECEIVED TRANSACTION => \(transaction)")
                
                // 단일 패킷을 인식하기 위해 SPLIT
                let splited = transaction.components(separatedBy: SOCKET_COMMON.DELIMITER)
                
                if(splited.count>0) {
                    
                    let typeCode = splited[0]
                    switch typeCode {
                        
                    case SOCKET_PROTOCOL_CODE.RESPONSE_CONNECTION_INFO:
                        let responseConnectionInfo = ResponseConnectionInfo(transaction: transaction)
                        if responseConnectionInfo!.connectionCode == 2000 {
                            //                            let screenAction = screenAction(statusCode: 140000 + responseConnectionInfo!.connectionCode )
                            //                            runScreenAction(screenAction:screenAction)
                            let userNum = responseConnectionInfo!.userNum
                            //                            let userMemNum = responseConnectionInfo!.userNum
                            let traderMngNum = responseConnectionInfo!.traderMngNum
                            //                            let auctionHouseCode = responseConnectionInfo!.auctionHouseCode
                            
                            LocalStorage.shared.setUserNum(userNum: userNum)
                            LocalStorage.shared.setTraderMngNum(traderMngNum: traderMngNum)
                            self.inputStream?.close()
                            self.outputStream?.close()
                            
                            // RESPONSE_CONNECTION_INFO 수신시
                            // 단일/일괄인지 판단하기 위해 0.2초 wait한 다음에 화면 이동
                            // 바로 화면이동할시에는 단일/일괄이 화면상에서 바로 표시가 안됨
                            _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {_ in
                                let controller = UIStoryboard.init(name: STORYBOARD.REALTIME, bundle: nil).instantiateViewController(withIdentifier: VIEWCONTROLLER.REALTIME) as! RealtimeViewController
                                controller.auctionCodeName = self.currentAuctionCodeName
                                // 관전모드
                                if self.clickObserverMode {
                                    controller.isObserverMode = true
                                    controller.observerModeToken = self.observerModeToken ?? ""
                                    controller.observerModeWebViewURL = self.observerModeURL ?? ""
                                }
                                //self.push(_ : controller, animated: true)
                                //2023.02.02 웹뷰 중복 호출로 인한 뷰 중복 방어 코드
                                let isNowNHWebViewController = self.navigationController?.topViewController?.isKind(of: NHWebViewController.self)
                                if let  check = isNowNHWebViewController {
                                    if (check) {
                                        self.push(_ : controller, animated: true)
                                    } else {
                                        //
                                    }
                                }
                            })
                            
                        } else if responseConnectionInfo!.connectionCode == 2002 {
                            //2023.02.03경매화면에서 보이지 않게 하기 위한 방어코드
                            let isNowNHWebViewController = self.navigationController?.topViewController?.isKind(of: NHWebViewController.self)
                            if let  check = isNowNHWebViewController {
                                if (check) {
                                    self.popupOneBtn(withTitle: TEXT.NOTICE, msg: "이미 접속한 사용자가 있습니다. ", buttonAction: nil)
                                    self.inputStream?.close()
                                    self.outputStream?.close()
                                    //23.03.23 웹뷰에서 경매 응찰 버튼 클릭시 이미접속한 사용자가 있습니다 메시지 확인클릭후 경매응찰 버튼 동작하지 않는 이슈
                                    //로직추가 웹뷰 경매응찰버튼 중복방지 초기화
                                    self.ischeckAuctionBid.toggle()
                                } else {

                                }
                            }
                        } else if responseConnectionInfo!.connectionCode == 2001 {
                            self.popupOneBtn(withTitle: TEXT.NOTICE, msg: "경매를 참여하실수 없습니다.\n 경매참여를 원하실 경우 관리자에게 문의하세요.", buttonAction: nil)
                            self.inputStream?.close()
                            self.outputStream?.close()
                            //웹뷰 경매응찰버튼 중복방지 초기화
                            self.ischeckAuctionBid.toggle()
                        } else {
                            self.popupOneBtn(withTitle: TEXT.NOTICE, msg: "현재 참여 가능한 경매가 없습니다.\n관리자에게 문의하세요.", buttonAction: nil)
                            self.inputStream?.close()
                            self.outputStream?.close()
                            //웹뷰 경매응찰버튼 중복방지 초기화
                            self.ischeckAuctionBid.toggle()
                        }
                        break
                    case SOCKET_PROTOCOL_CODE.AUCTION_TYPE:
                        let auctionType = AuctionType(transaction: transaction)
                        var batchSelection = false
                        if auctionType!.auctionType == "10" {
                            //일괄경매 모드
                            batchSelection = true
                        } else if auctionType!.auctionType == "20" {
                            // 단일경매 모드
                            batchSelection = false
                        }
                        LocalStorage.shared.setIsBatchSelection(isBatchSelection: batchSelection)
                        break
                    default:
                        debugPrint("WEBVIEW : undefined message\(transaction)")
                        break
                    }
                }
            } else {
                //
            }
        }
    }
}

