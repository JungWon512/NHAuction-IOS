//
//  ViewController.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/08/27.
//

import UIKit
import JWTDecode
//import RemoteMonster
import AgoraRtcKit
import Alamofire
import SwiftyJSON
import WebKit
import MarqueeLabel
import AVFAudio
import AudioToolbox
import SwiftProtobuf

class RealtimeViewController: BaseViewController, StreamDelegate,WKNavigationDelegate, WKUIDelegate{
    //UILabel
    @IBOutlet weak var lblEntryHeader1: UILabel!
    @IBOutlet weak var lblEntryHeader2: UILabel!
    @IBOutlet weak var lblEntryHeader3: UILabel!
    @IBOutlet weak var lblEntryHeader4: UILabel!
    @IBOutlet weak var lblEntryHeader5: UILabel!
    @IBOutlet weak var lblEntryHeader6: UILabel!
    @IBOutlet weak var lblEntryHeader7: UILabel!
    @IBOutlet weak var lblEntryHeader8: UILabel!
    @IBOutlet weak var lblEntryHeader9: UILabel!
    @IBOutlet weak var lblEntryHeader10: UILabel!
    @IBOutlet weak var batchEntryNum: UILabel!
    @IBOutlet weak var lblAuctionState: UILabel!
    @IBOutlet weak var lblStatusToast: UILabel!
    @IBOutlet weak var lblCurrentPrice: UILabel!
    @IBOutlet weak var lblUserNum: UILabel!
    @IBOutlet weak var lblCountDown: UILabel!
    @IBOutlet weak var lblAuctionCodeName: UILabel!
    //MarqueeLabel
    @IBOutlet weak var lblEntryText1: MarqueeLabel!
    @IBOutlet weak var lblEntryText2: MarqueeLabel!
    @IBOutlet weak var lblEntryText3: MarqueeLabel!
    @IBOutlet weak var lblEntryText4: MarqueeLabel!
    @IBOutlet weak var lblEntryText5: MarqueeLabel!
    @IBOutlet weak var lblEntryText6: MarqueeLabel!
    @IBOutlet weak var lblEntryText7: MarqueeLabel!
    @IBOutlet weak var lblEntryText8: MarqueeLabel!
    @IBOutlet weak var lblEntryText9: MarqueeLabel!
    @IBOutlet weak var lblEntryText10: MarqueeLabel!
    //UIButton
    @IBOutlet weak var btnNextPage: UIButton!
    @IBOutlet weak var btnPrevPage: UIButton!
    @IBOutlet weak var btnBatchEntry: UIButton!
    @IBOutlet weak var btnBatch0: UIButton!
    @IBOutlet weak var btnBatchPrev: UIButton!
    @IBOutlet weak var btnBackArrow: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSpeakerOnOff: UIButton!
    @IBOutlet weak var fullScreenBt: UIButton!
    @IBOutlet weak var btnNotice: UIButton!
    //UIView
    @IBOutlet weak var entryView: UIView!
    @IBOutlet weak var batchBottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var numberKeyView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var marginView: UIView!
    @IBOutlet var viewRoot: UIView!
    @IBOutlet weak var bidInfoView: UIView!
    @IBOutlet weak var observerModeBaseWebView: UIView!
    @IBOutlet weak var bidView: UIView! // 응찰 뷰
    //UIScrollView
    @IBOutlet weak var scrollView: UIScrollView!
    //UIPageControl
    @IBOutlet weak var pageControl: UIPageControl!
    //NSLayoutConstraint
    @IBOutlet weak var scrollViewAspect: NSLayoutConstraint!
    @IBOutlet weak var scrollviewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraint7Width: NSLayoutConstraint!
    @IBOutlet weak var constraint7Height: NSLayoutConstraint!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!

    public enum Exception: Error {
        case streamInitFailure
        case unreadyToWrite
        case unableToSetupReadTLS
        case unableToSetupWriteTLS
    }
    //RemoteMonster lib 셋팅 관련 변수
//    var customConfig: RemonConfig?
    var toChID: String?
    var socketErr = false
    ///RemoteMonster lib 방송 송출 관련 변수들
    var selectedChannelId: String?
//    var remonCast: RemonCast!
    
    // Agora lib 세팅 관련 변수
    var agoraEngine: AgoraRtcEngineKit!
    
    var currentReadyDelete: Int = 0
    var CHANNELS: [String] = []
    var ORG_CHANNELS: [String] = []
    var remonFirstClose: Bool = true
    var remoteView1 = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var currentCastPaused: Bool = false
    var selectedChannelIdTmp: String = ""
    //스크롤 페이징 관련 변수
    var oldPage: Int = 0
    var currentPage: Int = 0
    var oldCastPage: Int = 0
    var totalPage = 1
    //경매 관련 변수
    var currentBatchEntryNum = ""
    var batchSelection: Bool = false
    var isFirstEntry: Bool = false
    var batchBidMode: Bool = false
    var entryNum: String = ""
    var currentPrice: String = "0"
    var biddedDic: [String:String] = [:]
    var statusAbleBidding: Bool = false
    var globalCurrentEntryInfo: CurrentEntryInfo = CurrentEntryInfo(transaction: "")!
    var globalCurrentTransaction: String = ""
    var globalUnitType: String = "" // 단위 (원,만원)
    var userMemNum: String = ""
    var currentLowPrice: Int = 0
    var auctionHouseCode: String = ""
    var topValueShow: Bool = true
    // 재경매 후보자일때
    var retryTrue: Bool = false
    // 재경매 후보자 아닐때
    var retryFalse: Bool = false
    var nextResetPrice: Bool = false
    var retryStatus: Bool = false
    var auctionCodeName: String = ""
    // Socket
    // Socket Session Check Timer
    var scheduleTimer: Timer!
    var reconnectCount: Int = 0
    var status = SOCKET_STATUS.DISCONNECTED
    // Input and output streams for socket
    var inputStream: InputStream?
    var outputStream: OutputStream?
    //팝업 오픈 유무 변수
    var popupOpened: Bool = false
    // 관전모드
    var isObserverMode = false // 관전모드 유/무 flag
    var observerModeToken: String? // 관전모드 접속 시 token
    var observerModeWebViewURL: String? // 관전모드 웹뷰 url
    var observerModeWebView: BaseWKWebView?
    var popupWebView: WKWebView? // 팝업 뷰
    ///화면 회전 감지 관련 변수
    ///AppDelegate에서 정의한 화면 회전 변수에 접근할 수 있도록 AppDelegate 변수 선언
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var checkSceneRotate: Bool = false
    var svAspectConst: NSLayoutConstraint!
    var svBottomConst: NSLayoutConstraint!
    var svScreenBottomConst: NSLayoutConstraint!
    var isFullScreenBtCheck: Bool = false
    ///static let SUB_VIEW_TAG_BASE = 190001의 값으로 초깃값셋팅
    var remoteViewWithTagValue: [Int] = []
    ///가로모드시에만 사용할 현제페이지값
    var onlyUseHorizenModeCurrentPageValue: Int = 0
    ///가로모드시에만 사용할 offset.x 값
    var onlyUseHorizenModeScrollViewOffsetX: Double = 0.0
    ///addContentScrollView의 subView1의 width값
    var subView1Width: CGFloat = 0.0
    ///화면회전체크변수
    var isViewWillTransition: Bool = false
    /***
     상단에 Notch가 있는지 판별
     */
    var hasTopNotch: Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    /***
     Notch의 사이즈를 확인
     */
    var sizeTopNotch: Int {
        if #available(iOS 11.0,  *) {
            return Int(UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
        }
        return 0
    }
    //사용유무불명
    var connectionTimer: Timer?
    var CONNECTION_TIMEOUT: Double = 1000
    var countDownSeconds = 0
    var fullUIiew = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    var nearBranch: Bool = false
    var globalIsStartWithPause: Bool = false
    // Secondary delegate reference to prevent ARC deallocating the NSStreamDelegate
    var inputDelegate: StreamDelegate?
    var outputDelegate: StreamDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("viewDidLoad")
        //송출영상이 바닥까지 닫게 할 용도의 제약
        self.svScreenBottomConst = NSLayoutConstraint(
                                                item: self.scrollView!,
                                                attribute: .bottom,
                                                relatedBy: .equal,
                                                toItem: self.view,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: 0)
        isFirstEntry = true
        self.popupOpened = false
        lblAuctionCodeName.text = auctionCodeName
        LocalStorage.shared.setIsBackground(isBackground: false)
        UIApplication.shared.isIdleTimerDisabled = true

        btnSpeakerOnOff.setImage(UIImage(named: "speakerOn.png"), for: UIControl.State.selected)
        btnSpeakerOnOff.setImage(UIImage(named: "speakerOff.png"), for: UIControl.State.normal)
        LocalStorage.shared.setSpeakerOnOff(isOn: false) // Default 스피커 상태
        
        // 응찰취소 버튼 title 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.8
        paragraphStyle.lineBreakMode = .byCharWrapping
        
        let btnCancelAttributedTitle = NSAttributedString(string: "응찰\n취소",
                                                          attributes: [.foregroundColor: UIColor.white,
                                                                       .font: UIFont(name: "NotoSansCJKKR-Bold", size: 29)!,
                                                                       .paragraphStyle: paragraphStyle
                                                                      ])
        btnCancel.setAttributedTitle(btnCancelAttributedTitle, for: .normal)
        btnCancel.contentVerticalAlignment = .top
        scrollView.delegate = self
        let sockethost = LocalStorage.shared.getNetHost()
        let socketPort = LocalStorage.shared.getNetPort()
        #if DEBUG
//            sockethost = SOCKET.DEBUG_HOST
        #endif
        self.connect(host: sockethost, port: Int(socketPort)!)
        status = SOCKET_STATUS.DISCONNECTED

        self.agoraConnect(firstCall:true)
        
        pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);

        let priceViewBorderColor : UIColor = UIColor( red: 118/255, green: 186/255, blue:1, alpha: 1.0 )
        priceView.layer.masksToBounds = true
        priceView.layer.borderColor = priceViewBorderColor.cgColor
        priceView.layer.borderWidth = 2.0
        priceView.layer.cornerRadius = 2
        
        lblCurrentPrice.text = currentPrice
        
        setUpView()
        
        // 관전모드 유/무에 따라 view의 숨김 처리 변경
        self.bidView.isHidden = isObserverMode
        self.observerModeBaseWebView.isHidden = !isObserverMode
        
        // setup webview
        if isObserverMode {
            let userController = WKUserContentController()
            userController.add(self, name: "setCowInfo")
            let configuration = WKWebViewConfiguration()
            configuration.websiteDataStore = WKWebsiteDataStore.default()
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
            configuration.userContentController = userController
            HTTPCookieStorage.shared.cookieAcceptPolicy = .always
            observerModeWebView = BaseWKWebView.init(frame: .zero , configuration: configuration)
            observerModeWebView?.clearsContextBeforeDrawing = true
            observerModeWebView?.isOpaque = false
            observerModeWebView?.backgroundColor = .clear
            observerModeWebView?.uiDelegate = self
            observerModeWebView?.navigationDelegate = self
            observerModeWebView?.scrollView.isScrollEnabled = false
            observerModeWebView?.allowsLinkPreview = false
            self.observerModeBaseWebView.addSubview(observerModeWebView ?? UIView())
            self.observerModeWebView?.setAutolayout(withView: self.observerModeBaseWebView)
            // WEB.HOST + WEB.DEFAULT_URL
            guard let url = URL.init(string: self.observerModeWebViewURL ?? "") else { return }
            var request = URLRequest.init(url: url)
            request.httpShouldHandleCookies = true
            self.observerModeWebView?.load(request)
            self.view.backgroundColor = UIColor.white
        } else {
            self.view.backgroundColor = UIColor.init(hexString: COLOR.RGB_E6EFFF)
            //  23.02.07 경매 응찰화면에서 전체화면 버튼숨김 처리
            self.fullScreenBt.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        debugPrint("didDisappear")
        //경매관전 가로모드시 세로모드로 바꾸지 않고 가로모드상타에서 나갔을때 다시 세로모드로 전환을 강제함
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //화면이 가릴때 마다 AppDelegate화면 회전 변수 비활성화
        appDelegate.shouldSupportAllOrientation = false
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(self.totalPage), height: self.scrollView.frame.height)
        }
    }
    
    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = LocalStorage.shared.getAgoraAppId()
//        config.appId = "6d54495294dc44809cb28e937a18c5da"
        self.agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        self.agoraEngine.enableVideo()
        
    }
    
    func leaveChannel() {
        agoraEngine.stopPreview()
        agoraEngine.leaveChannel(nil)
        DispatchQueue.global(qos: .userInitiated).async {AgoraRtcEngineKit.destroy()}
    }
    
    func joinChannel() {
        let option = AgoraRtcChannelMediaOptions()
        
        option.clientRoleType = .audience
        option.audienceLatencyLevel = .lowLatency
        option.channelProfile = .liveBroadcasting
        
        // 추후 channelId 값 변경해야 함
        if let chID = self.toChID {
            let result = agoraEngine.joinChannel(
                byToken: "", channelId: chID, uid: 0, mediaOptions: option,
                joinSuccess: { (channel, uid, elapsed) in debugPrint("채널 조인 성공")}
            )
            // result가 성공이 아닐 경우
            if result != 0 {
                debugPrint("채널 조인 다시 시도")
                agoraEngine = AgoraRtcEngineKit()
                
                initializeAgoraEngine()
                
                agoraEngine.joinChannel(
                    byToken: "", channelId: chID, uid: 0, mediaOptions: option,
                    joinSuccess: { (channel, uid, elapsed) in debugPrint("채널 조인 성공")}
                )
            }
        }
    }
    
    func checkDynamicLinks(link: String ) {
        if self.status == SOCKET_STATUS.CONNECTED {
            //23.03.21 관전을 종료하고 메인화면으로 이동해도 관전 Voice 가 play 되는 이슈 대응  다이나믹 링크를 타고 들어 올 경우
            if self.agoraEngine != nil {
                self.leaveChannel()
            }
            self.inputStream?.close()
            self.outputStream?.close()
            self.pop(animated: true)
        }
    }
    /***
     응찰 종료 버튼 클릭시
     - Parameter sender:
     */
    @IBAction func top_arrow(_ sender: Any) {
        var popupMessage = "응찰을 종료하시겠습니까?"
        if isObserverMode {
            popupMessage = "관전을 종료하시겠습니까?"
        }
        self.popupTwoBtn(msg: popupMessage , rightTitle: "종료", leftBtnAction: nil, rightBtnAction: {
            if self.agoraEngine != nil {
                self.leaveChannel()
            }
            self.inputStream?.close()
            self.outputStream?.close()
            self.pop(animated: true)
        })
    }

    /***
     일괄경매에서 확인버튼 터치할때
     - Parameter sender:
     */
    @IBAction func btnBatchEntryTouched(_ sender: Any) {
            //300000
            if currentBatchEntryNum == "0" {
                let screenAction = screenAction(statusCode: 300001)
                runScreenAction(screenAction:screenAction)
                return ;
            } else {
                actRequestEntryInfo(entryNum: currentBatchEntryNum)
            }
    }

    /***
     경매항목설명의 보여줄지 결정
     */
    func showHideTopValue(){
        let entryTextAlpha: CGFloat = topValueShow == true ? 1 : 0
        lblEntryText1.alpha = entryTextAlpha
        lblEntryText2.alpha = entryTextAlpha
        lblEntryText3.alpha = entryTextAlpha
        lblEntryText4.alpha = entryTextAlpha
        lblEntryText5.alpha = entryTextAlpha
        lblEntryText6.alpha = entryTextAlpha
        lblEntryText7.alpha = entryTextAlpha
        lblEntryText8.alpha = entryTextAlpha
        lblEntryText9.alpha = entryTextAlpha
        lblEntryText10.alpha = entryTextAlpha
    }

    /**
     KAKAOConnect값을 다시 불러 오는 method
     - Parameter firstCall: 최초호출 여부
     */
    func agoraConnect(firstCall: Bool) {
        
        callAgoraConnect() { result in
            if result.isSuccess, let agoraConnect = result.value, agoraConnect.success  {

                guard let agoraInfo = agoraConnect.kkoInfo else { return }
                
                debugPrint("agoraInfo >>> KKO_SVC_KEY : \(agoraInfo.KKO_SVC_KEY) KKO_SVC_CNT : \(agoraInfo.KKO_SVC_CNT)")
                
                LocalStorage.shared.setAgoraAppId(agoraAppId: agoraInfo.KKO_SVC_KEY)
                if self.agoraEngine == nil {
                    self.agoraEngine = AgoraRtcEngineKit()
                }
                self.initializeAgoraEngine()
                
                self.CHANNELS = Array(repeating: "", count: agoraInfo.KKO_SVC_CNT)
                for i in 0..<agoraInfo.KKO_SVC_CNT {
                    self.CHANNELS[i] = LocalStorage.shared.getNaBzPlc() + "-remoteVideo" + String(i+1)
                }
                
                if firstCall {
                    self.addContentScrollView()
                    // 화면 회전후 prevbt, nextbt 싱크 맞지 않는것 수정, 추후 리펙토링
                    if (self.isViewWillTransition == true) {
                        self.isViewWillTransition.toggle()
                        self.pageControl.currentPage = self.onlyUseHorizenModeCurrentPageValue
                        self.pageControl.numberOfPages = self.CHANNELS.count
                        self.pageControl.pageIndicatorTintColor = UIColor.init(hexString: COLOR.RGB_DBDBDB)
                        self.pageControl.currentPageIndicatorTintColor = UIColor.init(hexString: COLOR.RGB_007EFF)
                        self.setPageControlSelectedPage(currentPage: self.onlyUseHorizenModeCurrentPageValue)
                    } else {
                        self.pageControl.currentPage = 0
                        self.pageControl.numberOfPages = self.CHANNELS.count
                        self.pageControl.pageIndicatorTintColor = UIColor.init(hexString: COLOR.RGB_DBDBDB)
                        self.pageControl.currentPageIndicatorTintColor = UIColor.init(hexString: COLOR.RGB_007EFF)
                        self.setPageControlSelectedPage(currentPage: self.currentPage)
                    }
                } else {
                    self.hideAndShowCast(oldPage : self.currentPage, currentPage : self.currentPage, isSpeakerOn : LocalStorage.shared.getIsSpeakerOnOff())
                }
            }
        }
    }
    
    /***
     - 스피커 mute모드 설정
     - Parameter input: true일때는 speaker mute모드
     */
    func setMute(input:Bool) {
        guard self.agoraEngine != nil else { return }
        if input == true {
            agoraEngine.adjustPlaybackSignalVolume(0)
            agoraEngine.adjustAudioMixingPlayoutVolume(0)
        } else {
            agoraEngine.adjustPlaybackSignalVolume(100)
            agoraEngine.adjustAudioMixingPlayoutVolume(100)
        }
    }

    /***
     상단우측의 스피커를 터치할때 동작하는 method
     - Parameter sender:
     */
    @IBAction func top_speaker(_ sender: Any) {
        btnSpeakerOnOff.isSelected = !btnSpeakerOnOff.isSelected
        
        LocalStorage.shared.setSpeakerOnOff(isOn: btnSpeakerOnOff.isSelected)
        if  btnSpeakerOnOff.isSelected {
            setMute(input: false)
            if self.currentPage == 0 {
                hideAndShowCast(oldPage : 0, currentPage : 0, isSpeakerOn : true)
            }
        } else {
            setMute(input: true)
            if self.currentPage == 0 {
                hideAndShowCast(oldPage : 0, currentPage : 0, isSpeakerOn : false)
                addReadyToCast(position:1)
            }
        }
    }
    
    /***
     경매상태클릭서 동작하는 method
     - Parameter sender:
     */
    @IBAction func noticeTouched(_ sender: Any) {
        let fullUIView:UIView = UIView(frame: CGRect(x: 0, y: 38, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-38))
        fullUIView.layer.zPosition = 1
        let closeView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        closeView.backgroundColor = .white
        
        let userController = WKUserContentController()
        userController.add(self, name: "setAucPrgSq")
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.userContentController = userController;
        
        let myWebView:WKWebView = WKWebView(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-38-40), configuration: configuration)
        myWebView.uiDelegate = self
        myWebView.navigationDelegate = self

        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.layer.add(transition, forKey: nil)
        
        let button = UIButton(frame: CGRect(x: 15, y: 15, width: 20, height: 20))
        button.setImage(UIImage(named: "closeWindow.png"), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        closeView.addSubview(button)
        fullUIView.addSubview(closeView)
        fullUIView.tag = 201020
        
        fullUIView.addSubview(myWebView)
        self.view.addSubview(fullUIView)
        let tradeMngNum = LocalStorage.shared.getTraderMngNum()

        let auctionPopupUrl = "\(WEB.HOST)\(String(format: WEB.AUCTION_POPUP, arguments: [auctionHouseCode,tradeMngNum]))"
        
        let myURL = URL(string: auctionPopupUrl)
        let myURLRequest:URLRequest = URLRequest(url: myURL!)
        myWebView.load(myURLRequest)

        self.showSpinner(onView: self.view)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint("loaded")
        self.removeSpinner()
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
        popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupWebView?.navigationDelegate = self
        popupWebView?.uiDelegate = self
        view.addSubview(popupWebView!)
        return popupWebView!
    }

    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        popupWebView = nil
    }
    
    /***
     경매진행상태의 X 를 클릭시 동작하는 method
     - Parameter sender:
     */
    @objc func buttonAction(sender: UIButton!) {
        let oldFullUIView = (self.view.viewWithTag(201020) ?? UIView())
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        oldFullUIView.removeFromSuperview()
    }

    /**
     이전페이지 터치시 동작하는 method
     - Parameter sender:
     */
    @IBAction func touchPrevPage(_ sender: Any) {
        currentPage = currentPage - 1
        self.remonFirstClose = true
        self.scrollToPage(page:currentPage, animated: true)
        //23.02.06 경매응찰,관전 페이지에서 이전,이후 버튼을 클릭후 화면회전시 해당페이지 스크롤이 되지 않았던 것 수정
        self.onlyUseHorizenModeCurrentPageValue = currentPage
        setPageControlSelectedPage(currentPage: self.onlyUseHorizenModeCurrentPageValue)
    }

    /***
     이후페이지 터치시 동작하는 method
     - Parameter sender:
     */
    @IBAction func touchNextPage(_ sender: Any) {
        self.remonFirstClose = true
        currentPage = currentPage + 1
        if (currentPage == totalPage) {
            currentPage = 0
        }
        self.scrollToPage(page:currentPage, animated: true)
        
        guard currentPage != 0 else { return }
        //23.02.06 경매응찰,관전 페이지에서 이전,이후 버튼을 클릭후 화면회전시 해당페이지 스크롤이 되지 않았던 것 수정 
        self.onlyUseHorizenModeCurrentPageValue = currentPage
        setPageControlSelectedPage(currentPage: self.onlyUseHorizenModeCurrentPageValue)
    }

    /***
     키패드에서 백스페이스 터치시 동작하는 method
     - Parameter sender:
     */
    @IBAction func keypad_arrow(_ sender: Any) {
        impact()
        if batchSelection {
            if batchBidMode {
                if (currentPrice != "0") {
                    // 22.04.27 ver 1.0.5 update
                    // 맨 끝에 한자리 삭제가 아닌 전체 삭제로 수정
                    currentPrice = "0"
                    lblCurrentPrice.textColor = .black
                } else {
                    
                }
                lblCurrentPrice.textColor = .black
                lblCurrentPrice.text = Int(currentPrice)?.withCommas()
            } else {
                // 22.04.27 ver 1.0.5 update
                // 맨 끝에 한자리 삭제가 아닌 전체 삭제로 수정
                currentBatchEntryNum = "0"
            }
            batchEntryNum.text = currentBatchEntryNum
            if currentBatchEntryNum == "0" {
                batchEntryNum.isHidden = true
            } else {
                batchEntryNum.isHidden = false
            }
        } else {
            if (currentPrice != "0") {
                // 22.04.27 ver 1.0.5 update
                // 맨 끝에 한자리 삭제가 아닌 전체 삭제로 수정
                currentPrice = "0"
            } else {
                
            }
            lblCurrentPrice.textColor = .black
            lblCurrentPrice.text = Int(currentPrice)?.withCommas()
        }
    }

    /***
     숫자 키패드 터치시 동작하는 method
     - Parameter sender:
     */

    @IBAction func keypad_0(_ sender: Any) {
        keypadPressed(text:"0")
    }

    @IBAction func keypad_1(_ sender: Any) {
        keypadPressed(text:"1")
    }
    
    @IBAction func keypad_2(_ sender: Any) {
        
        keypadPressed(text:"2")
    }
    
    @IBAction func keypad_3(_ sender: Any) {
        keypadPressed(text:"3")
    }

    @IBAction func keypad_4(_ sender: Any) {
        keypadPressed(text:"4")
    }
    
    @IBAction func keypad_5(_ sender: Any) {
        keypadPressed(text:"5")
    }

    @IBAction func keypad_6(_ sender: Any) {
        keypadPressed(text:"6")
    }
    
    @IBAction func keypad_7(_ sender: Any) {
        keypadPressed(text:"7")
    }
    
    @IBAction func keypad_8(_ sender: Any) {
        keypadPressed(text:"8")
    }
    
    @IBAction func keypad_9(_ sender: Any) {
        keypadPressed(text:"9")
    }

    /***
     키패드 동작용 method
     - Parameter text: 입력된 숫자
     */
    func keypadPressed(text:String) {
        if batchSelection {
            if nextResetPrice == true {
                currentPrice = "0"
                nextResetPrice = false
            }
            if batchBidMode {
                impact()
                if (currentPrice.count < 5) {
                    if currentPrice == "0" {
                        currentPrice = text
                    } else {
                        currentPrice.append(text)
                    }
                }
                lblCurrentPrice.text = Int(currentPrice)?.withCommas()
                lblCurrentPrice.textColor = .black
            } else {
                if currentBatchEntryNum == "0" {
                    currentBatchEntryNum = ""
                }
                if (currentBatchEntryNum.count < 4) {
                    currentBatchEntryNum.append(text)
                    batchEntryNum.text = currentBatchEntryNum
                    if currentBatchEntryNum == "0" {
                        batchEntryNum.isHidden = true
                    } else {
                        batchEntryNum.isHidden = false
                    }
                }
            }
        } else {
            if nextResetPrice == true {
                currentPrice = ""
                nextResetPrice = false
            }
            impact()
            if (currentPrice.count < 5) {
                if currentPrice == "0" {
                    currentPrice = text
                } else {
                    currentPrice.append(text)
                }
            }
            lblCurrentPrice.text = Int(currentPrice)?.withCommas()
            lblCurrentPrice.textColor = .black
        }
    }

    /***
     해당페이지로 가로 스크롤 하는 method
     - Parameters:
       - page:
       - animated:
     */
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: animated)
        debugPrint("scrollTopage \(page)")
    }

    /***
     일괄/단일 경매로 화면전환
     - Parameters:
       - batchSelection: 일괄여부
       - batchBidMode: 일괄시 경매번호입력(false)/ 경매금액입력(true)
     */
    func setupBatchBid(batchSelection:Bool, batchBidMode:Bool){
        
        guard !isObserverMode else { return }
        
        if batchSelection {
            batchBottomView.isHidden = false
            if batchBidMode {
                btnBatchEntry.isHidden = true
                entryView.isHidden = true
                topValueShow = true
                showHideTopValue()
            } else {
                // 경매번호를 입력하세요.
                btnBatchEntry.isHidden = false
                entryView.isHidden = false
                topValueShow = false
                showHideTopValue()
            }
        } else {
            batchBottomView.isHidden = true
            btnBatchEntry.isHidden = true
            entryView.isHidden = true
            topValueShow = true
            showHideTopValue()
        }
        if currentBatchEntryNum == "0" {
            batchEntryNum.isHidden = true
        } else {
            batchEntryNum.isHidden = false
        }
    }


    /***
     응찰버튼 터치시 동작하는 method
     - Parameter sender:
     */
    @IBAction func keypad_bid(_ sender: Any) {
        impact()
        if ( retryStatus == true && retryFalse == true) {
            
            let screenAction = screenAction(statusCode: 150010)
            runScreenAction(screenAction:screenAction)
        } else {
            debugPrint("응찰")
            if ableBidding() == true {
                if currentPrice == "0" {
                    let screenAction = screenAction(statusCode: 150001)
                    runScreenAction(screenAction:screenAction)
                } else if Int(currentPrice)! < currentLowPrice {
                    let screenAction = screenAction(statusCode: 150002)
                    runScreenAction(screenAction:screenAction)
                    currentPrice = "0"
                    lblCurrentPrice.text = Int(currentPrice)?.withCommas()
                    lblCurrentPrice.textColor = .black
                } else {
                    actBidding()
                    if batchSelection && batchBidMode {
                        currentBatchEntryNum = "0"
                        batchEntryNum.text = currentBatchEntryNum
                        // 일괄일때만 사라지게 함.
                        nextResetPrice = true
                    }
                    if !batchSelection {
                        nextResetPrice = true
                    }
                }
            } else {
//                self.showToastNH(text: "현재 응찰 가능상태가 아닙니다.")
                let screenAction = screenAction(statusCode: 150003)
                runScreenAction(screenAction:screenAction)
            }
        }
    }

    /***
     응찰취소 버튼 터치시 동작하는 method
     - Parameter sender:
     */
    @IBAction func keypad_cancel(_ sender: Any) {
        if batchSelection && !batchBidMode {
            currentBatchEntryNum = "0"
            batchEntryNum.text = currentBatchEntryNum
            
        } else {
        debugPrint("취소")
        if retryFalse == true {
//            self.showToastNH(text: "재경매 대상이 아닙니다.")
            let screenAction = screenAction(statusCode: 261002)
            runScreenAction(screenAction:screenAction)
        } else if retryTrue == true {
//            self.showToastNH(text: "응찰 취소를 할수 없습니다.")
            let screenAction = screenAction(statusCode: 261001)
            runScreenAction(screenAction:screenAction)
            
        } else
        
            if ableBidding() == true {
                if retryStatus == true {
                    if retryFalse == true {
            //            self.showToastNH(text: "재경매 대상이 아닙니다.")
                        let screenAction = screenAction(statusCode: 261002)
                        runScreenAction(screenAction:screenAction)
                    } else if retryTrue == true {
            //            self.showToastNH(text: "응찰 취소를 할수 없습니다.")
                        let screenAction = screenAction(statusCode: 261001)
                        runScreenAction(screenAction:screenAction)
                        
                    }
                } else {
                
                    let screenAction1 = screenAction(statusCode: 260000)
                    runScreenAction(screenAction:screenAction1)
                    impact()
                    actCancelBidding()
                    currentPrice = "0"
                    lblCurrentPrice.textColor = .black
                    lblCurrentPrice.text = Int(currentPrice)?.withCommas()
                    if batchSelection {
                    
                    } else {
                        let screenAction3 = screenAction(statusCode: 260001)
                        runScreenAction(screenAction:screenAction3)
                    }
                }
            } else {
                let screenAction = screenAction(statusCode: 261003)
                runScreenAction(screenAction:screenAction)
            }
        }
    }

    @IBAction func keypad_batch_0(_ sender: Any) {
        keypadPressed(text:"0")
    }

    /***
     응찰 가능한 상태인지 확인하는 method
     - Returns:
     */
    func ableBidding() -> Bool {
        
        var result = false
        if status == SOCKET_STATUS.CONNECTED && statusAbleBidding == true {
            result = true
        } else {
            result = false
        }
        return result
    }

    /***
     socket으로 접속하는 method
     - Parameters:
       - host: 호스트
       - port: 포트
     */
    func connect(host: String, port: Int) {
        let _ = Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        inputStream!.delegate = self
        outputStream!.delegate = self

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
     소켓으로 데이터 전송하는 method
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
     동영상 컨텐츠를 담을 스크롤뷰에 영역을 추가하는 method
     */
    private func addContentScrollView() {
        let streamCount = self.CHANNELS.count
        self.totalPage = streamCount + 1
        if (streamCount > 0) {
            for (index, _)  in self.CHANNELS.enumerated() {
                let position = index
                
                //여백 없음.
                let subView1 = UIView(frame:CGRect(x:self.scrollView.frame.width * CGFloat(position+1), y:0, width:self.scrollView.frame.width, height:self.scrollView.frame.height))

                subView1.backgroundColor = UIColor(hexString:COLOR.RGB_394161)

                //실시간 영상 준비중 텍스트 추가 필요
                subView1.tag = VIEW_TAG.SUB_VIEW_TAG_BASE + position
                self.remoteViewWithTagValue.append(subView1.tag)
                scrollView.addSubview(subView1)
                addReadyToCast(position: position + 1)
            }
        }
    }

    /***
     "실시간 경매준비중입니다." 이미지 터치시 동작하는 method
     - Parameter sender:
     */
    @objc func imageReadyTapped(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            debugPrint("터치 이벤트")
            self.remonFirstClose = true
            agoraConnect(firstCall: false)
        }
    }

    /***
     실시간 경매 준비중입니다 이미지를 추가하는 이벤트
     - Parameter position: 추가할 페이지
     */
    func addReadyToCast(position:Int) {
        // "!" 표기로 인해 발생되는 오류 수정
        guard let subView = (self.view.viewWithTag(VIEW_TAG.SUB_VIEW_TAG_BASE + position - 1)) else {return}
        let oldImageView = (self.view.viewWithTag(VIEW_TAG.READY_CAST_TAG_BASE + position - 1))
        
        if oldImageView != nil {
            oldImageView?.removeFromSuperview()
        }
        
        let imageName = "readyBroadcast.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        //여백 없음
        imageView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: scrollView.frame.height)
        
        
        let attributedString = NSMutableAttributedString(string: "실시간 영상 서비스\n준비 중입니다.", attributes: [
            .font: UIFont(name: "NotoSansCJKKR-Medium", size: 34.5)!,
          .foregroundColor: UIColor.white,
          .kern: -1.5
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 118.0 / 255.0, green: 186.0 / 255.0, blue: 1.0, alpha: 1.0), range: NSRange(location: 11, length: 4))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: scrollView.frame.height))
        label.center = CGPoint(x: self.scrollView.frame.width/2, y: scrollView.frame.height/2)
        label.textAlignment = .center
        label.attributedText = attributedString
        label.numberOfLines = 2
        imageView.addSubview(label)
        imageView.tag = VIEW_TAG.READY_CAST_TAG_BASE + position - 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageReadyTapped)))

        if self.view.viewWithTag(imageView.tag) == nil {
            imageView.contentMode = .scaleToFill
            subView.addSubview(imageView)
        }
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
    
    /***
    소켓으로 데이터 전송 low level
    - Parameter elements:
    */
    public func write(_ string: String = "") throws -> Int {
        debugPrint("SEND \(string)")
        let bytes:[UInt8] = string.utf8.map { $0 }
        return try self.send(bytes)
    }

    /***
         데이터 수신 이벤트
     - Parameters:
       - aStream: 수신되는 stream
       - eventCode: eventCode
     */
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
         switch eventCode {
         case Stream.Event.endEncountered:
             socketDisconnected()
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
                 reconnectCount = 0
                 if status == SOCKET_STATUS.DISCONNECTED {
                     do {
                         try _ = self.write(connectionInfo(isObserverMode: self.isObserverMode, self.observerModeToken))
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
             /**
              23.03.17 경매진행프로그램 실행 -> 종료 -> 실행시 iOS APP 죽는 이슈
             원인 : let str: String! = String(cString: buffer) 호출 되었을때 buffer가 null 종료 문자열('\0')로 끝나지 않았을때에 대한 처리가 되어 있지 않아서
              input of String.init(cString:) must be null-terminated 에러 발생 앱 사망
             기존 코드
              //            if bytesRead != nil {
              //                let str: String! = String(cString: buffer)
              //                parseReceive(transactions: str)
              //            } else {
              //                debugPrint("Receive String is nil")
              //            }
              */
             // 해결: Data형식으로 변환하고 String형식으로 다시 변환하여 parseReceive 처리 한다.
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
             socketDisconnected()
             break
         default:
             debugPrint("Default")
             break
         }
     }
    
    /***
     수신된 패킷정보를 처리하기 위한 method
     - Parameter transactions: 멀티 패킷 ASCII정보
     */
    func parseReceive(transactions: String){
        // 멀티패킷을 싱글 패킷으로 split
        let transactionArr = transactions.components(separatedBy: SOCKET_COMMON.TERMINATOR)
        debugPrint("RECEIVED TRANSACTIONs => \(transactionArr)")

        for transaction in transactionArr {
            
            if (transaction.count > 1) {
                debugPrint("RECEIVED TRANSACTION => \(transaction)")
                // 싱글패킷을 파싱하기 위해 split
                let splited = transaction.components(separatedBy: SOCKET_COMMON.DELIMITER)

                if (splited.count > 0) {

                    let typeCode = splited[0]
                    if typeCode == "AN" {
                        debugPrint("AN is called")
                    }
                    debugPrint("TYPECODE=>\(typeCode)")
                    switch typeCode {
                    case SOCKET_PROTOCOL_CODE.RESPONSE_CONNECTION_INFO:
                        let responseConnectionInfo = ResponseConnectionInfo(transaction: transaction)
                        if responseConnectionInfo!.connectionCode == 2000 {
                            let screenAction = screenAction(statusCode: 140000 + responseConnectionInfo!.connectionCode )
                            runScreenAction(screenAction:screenAction)
                            let userNum = responseConnectionInfo!.userNum
                            userMemNum = responseConnectionInfo!.userNum
                            let traderMngNum = responseConnectionInfo!.traderMngNum
                            auctionHouseCode = responseConnectionInfo!.auctionHouseCode
                            if userNum != "", !isObserverMode { // 관리자 모드인 경우 참가번호 표시하지 않는다.
                                lblUserNum.text = "참가번호 : \(userNum)번"
                            }
                            LocalStorage.shared.setUserNum(userNum: userNum)
                            LocalStorage.shared.setTraderMngNum(traderMngNum: traderMngNum)
                            
                        } else {
                            status = SOCKET_STATUS.DISCONNECT_FOR_BACK
                            let screenAction = screenAction(statusCode: 140000 + responseConnectionInfo!.connectionCode )
                            runScreenAction(screenAction:screenAction)
                        }
                        break
                    case SOCKET_PROTOCOL_CODE.TOAST_MESSAGE:
                        let toastMessage = ToastMessage(transaction: transaction)
                        let screenAction = screenAction(statusCode: 190000, message: toastMessage!.msg)
                        runScreenAction(screenAction:screenAction)
                        break
                    case SOCKET_PROTOCOL_CODE.AUCTION_TYPE:
                        // 관전 모드가 아닌 경우에만 일괄,단일 변수 설정
                        if !isObserverMode {
                            let auctionType = AuctionType(transaction: transaction)
                            if auctionType!.auctionType == "10" {
                                    //일괄경매 모드
                                batchSelection = true
                                setupBatchBid(batchSelection: batchSelection, batchBidMode: false)
                                    //                            topValueShow = false
                                batchBidMode = false
                                    //                            showHideTopValue()
                            } else if auctionType!.auctionType == "20" {
                                    // 단일경매 모드
                                batchSelection = false
                                setupBatchBid(batchSelection: batchSelection, batchBidMode: false)
                            }
                        }
                        
                        LocalStorage.shared.setIsBatchSelection(isBatchSelection: batchSelection)

                        break
                    case SOCKET_PROTOCOL_CODE.AUCTION_BID_STATUS:
                        let auctionBidStatus = AuctionBidStatus(transaction: transaction)
                        let screenAction2 = screenAction(statusCode: 360000, message: auctionBidStatus!.biddingStatus)
                        if (retryStatus == true && retryTrue == true)  {
                            if auctionBidStatus!.biddingStatus == "P" {
                                screenAction2.attributedString  = STATUS_VIEW.init(string: "재응찰 하시기 바랍니다.", blueStart: 0, blueLength: 3)!.attrString
                                runScreenAction(screenAction: screenAction2)
                            }
                            if auctionBidStatus!.biddingStatus == "F" {
                                runScreenAction(screenAction: screenAction2)
                            }
                        }
                        if (retryStatus == true && retryTrue == false)  {
                            if auctionBidStatus!.biddingStatus == "F" {
                                runScreenAction(screenAction: screenAction2)
                            }
                        }
                        if retryStatus == false && statusAbleBidding == true && auctionBidStatus?.entryNum ==  globalCurrentEntryInfo.entryNum {
                            if auctionBidStatus!.biddingStatus == "P" || auctionBidStatus!.biddingStatus == "F"  {
                                runScreenAction(screenAction: screenAction2)
                            }
                        } else if (retryStatus == false && retryTrue == false)  {
                            if auctionBidStatus!.biddingStatus == "P" || auctionBidStatus!.biddingStatus == "F"  {
                                runScreenAction(screenAction: screenAction2)
                            }
                        }
                        if  auctionBidStatus!.biddingStatus == "F"  {
                            statusAbleBidding = false
                        }
                        break
                    case SOCKET_PROTOCOL_CODE.RESPONSE_CODE:
                        let responseCode = ResponseCode(transaction: transaction)
                        var screenAction2 = screenAction(statusCode: 200000 + responseCode!.code)
                        if !isObserverMode {
                            // 관전모드가 아닌 경우에만 "진행중인 경매가 없습니다." 팝업 표시.
                            runScreenAction(screenAction: screenAction2)
                        }
                        if batchSelection {
                            if responseCode!.code == 4001 {
                                currentBatchEntryNum = "0"
                                batchEntryNum.text = currentBatchEntryNum
                            }
                            if responseCode!.code == 4006 {
                                currentBatchEntryNum = "0"
                                batchEntryNum.text = currentBatchEntryNum
                                currentPrice = "0"
                                lblCurrentPrice.text = currentPrice
                                lblCurrentPrice.textColor = .black
                                batchBidMode = false
                                setupBatchBid(batchSelection: batchSelection, batchBidMode: batchBidMode)
                                if batchSelection && !batchBidMode{
                                    screenAction2 = screenAction(statusCode: 201001)
                                    runScreenAction(screenAction:screenAction2)
                                }
                            }
                            if responseCode!.code == 4007 {
                                currentBatchEntryNum = "0"
                                batchEntryNum.text = currentBatchEntryNum
                                currentPrice = "0"
                                lblCurrentPrice.textColor = .black
                                lblCurrentPrice.text = currentPrice
                                batchBidMode = false
                                setupBatchBid(batchSelection: batchSelection, batchBidMode: batchBidMode)
                                if batchSelection && !batchBidMode {
                                    screenAction2 = screenAction(statusCode: 201001)
                                    runScreenAction(screenAction:screenAction2)
                                }
                            }
                        }
                        break
                    case SOCKET_PROTOCOL_CODE.AUCTION_RESULT:
                        let auctionResult = AuctionResult(transaction: transaction)
                        let resultCode = Int(auctionResult!.auctionResultCode)!
                        var unitTypeValue = "만 원" // Default
                        // 출장우가 비육우, unitType이 1인 경우 "원"으로 표시
                        if globalCurrentEntryInfo.entryType == "2" && globalUnitType == "1" {
                            unitTypeValue = "원"
                        }

                        let screenAction = screenAction(statusCode: 250000 + resultCode, message: auctionResult!.userNum, String(auctionResult!.price), unitTypeValue)
                        runScreenAction(screenAction:screenAction)
                        break
                    case SOCKET_PROTOCOL_CODE.SHOW_ENTRY_INFO:
                        if !isObserverMode {
                            let showEntryInfo = ShowEntryInfo.init(transaction: transaction)
                            
                            // 원, 만원 표시를 위한 단위 타입 저장
                            if let unitType = showEntryInfo?.unitType {
                                self.globalUnitType = unitType
                            }
                            
                            let tuple: (Bool, [String]) = actShowEntryInfo(showEntryInfo: showEntryInfo!)
                            if tuple.0 == true {
                                
                                lblEntryHeader1.text = ""
                                lblEntryHeader2.text = ""
                                lblEntryHeader3.text = ""
                                lblEntryHeader4.text = ""
                                lblEntryHeader5.text = ""
                                lblEntryHeader6.text = ""
                                lblEntryHeader7.text = ""
                                lblEntryHeader8.text = ""
                                lblEntryHeader9.text = ""
                                lblEntryHeader10.text = ""
                                
                                for (index, elem) in tuple.1.enumerated() {
                                    
                                    var labelString = "";
                                    if elem != "-" {
                                        labelString = actEntryText(position: Int(elem)! - 1)
                                    } else {
                                        labelString = ""
                                    }
                                    switch index {
                                    case 0:
                                        lblEntryHeader1.text = labelString
                                        if labelString == "" {
                                            lblEntryText1.text = ""
                                        }
                                    case 1:
                                        lblEntryHeader2.text = labelString
                                        if labelString == "" {
                                            lblEntryText2.text = ""
                                        }
                                    case 2:
                                        lblEntryHeader3.text = labelString
                                        if labelString == "" {
                                            lblEntryText3.text = ""
                                        }
                                    case 3:
                                        lblEntryHeader4.text = labelString
                                        if labelString == "" {
                                            lblEntryText4.text = ""
                                        }
                                    case 4:
                                        lblEntryHeader5.text = labelString
                                        if labelString == "" {
                                            lblEntryText5.text = ""
                                        }
                                    case 5:
                                        lblEntryHeader6.text = labelString
                                        if labelString == "" {
                                            lblEntryText6.text = ""
                                        }
                                    case 6:
                                        lblEntryHeader7.text = labelString
                                        if labelString == "" {
                                            lblEntryText7.text = ""
                                        }
                                    case 7:
                                        lblEntryHeader8.text = labelString
                                        if labelString == "" {
                                            lblEntryText8.text = ""
                                        }
                                    case 8:
                                        lblEntryHeader9.text = labelString
                                        if labelString == "" {
                                            lblEntryText9.text = ""
                                        }
                                    case 9:
                                        lblEntryHeader10.text = labelString
                                        if labelString == "" {
                                            lblEntryText10.text = ""
                                        }
                                    default:
                                        break
                                    }
                                }
                                LocalStorage.shared.setEntryHeaderIndex(headerListIndex: tuple.1)
                            }
                        }
                        if globalCurrentTransaction != "" {
                            parseReceive(transactions: globalCurrentTransaction)
                        }
                        break
                    case SOCKET_PROTOCOL_CODE.AUCTION_CHECK_SESSION:
                        if status == SOCKET_STATUS.CONNECTED {
                            
                            let auctionResponseSession =
                            AuctionResponseSession.init()
                            auctionResponseSession.userNum = LocalStorage.shared.getUserNum()
                            if isObserverMode {
                                auctionResponseSession.channel  = SOCKET_COMMON.REQUEST_CONNECTION_OBSERVERMODE_CHANNEL
                            } else {
                                auctionResponseSession.channel  = SOCKET_COMMON.REQUEST_CONNECTION_CHANNEL
                            }
                            auctionResponseSession.osType = "IOS"
                            
                            do {
                                try _ = self.write(auctionResponseSession.toString())
                                // 네트워크 연결 상태가 비정상인지 커넥션 상태 확인 타이머 시작 2021.12.24 jspark
                                startCheckSessionTimer()
                            } catch {
                                debugPrint(error)
                            }
                        }
                        break
                    case SOCKET_PROTOCOL_CODE.RESPONSE_BIDDING_INFO:
                        let responseBiddingInfo = ResponseBiddingInfo.init(transaction: transaction)!
                        let currentPrice = responseBiddingInfo.biddingPrice
                        lblCurrentPrice.text = currentPrice
                        break

                    case SOCKET_PROTOCOL_CODE.AUCTION_COUNT_DOWN:
                        let actionCountDown = ActionCountDown.init(transaction: transaction)

                        let screenAction = screenAction(statusCode: 180000 , message: actionCountDown!.status, String(actionCountDown!.sec) )
                        runScreenAction(screenAction:screenAction)
                        if actionCountDown!.status == "C" {
                            lblCountDown.isHidden = false
                            lblCountDown.text = String(actionCountDown!.sec)
                        } else {
                            lblCountDown.isHidden = true
                        }
                        break

                    case SOCKET_PROTOCOL_CODE.CURRENT_ENTRY_INFO:
                        // 재경매 모드 해제
                        retryTrue = false
                        retryFalse = false
                        retryStatus = false
                        let currentEntryInfo = CurrentEntryInfo.init(transaction: transaction)
                        currentLowPrice = currentEntryInfo!.lowPrice
                        if batchSelection  {
                            callNearAtdrAm(lvstAucPtcMnNo: self.userMemNum, aucPrgSq: currentEntryInfo!.entryNum, aucObjDsc: currentEntryInfo!.entryType ) {
                                result in
                                let atdr = result.value!
                                
                                switch atdr.success {
                                   //(우선 순위 1. 이전 응찰가, 2. 찜가격)
                                case true:
                                    
                                    if (atdr.data!.bidPrice != 0 ) {
                                        self.currentPrice = String(atdr.data!.bidPrice)
                                        self.lblCurrentPrice.text = Int(self.currentPrice)?.withCommas()
                                        self.lblCurrentPrice.textColor = .black
                                        self.nextResetPrice = true
                                    } else {
                                        if (atdr.data!.zimPrice != 0 ) {
                                            self.currentPrice = String(atdr.data!.zimPrice)
                                            
                                            let attributedString = NSMutableAttributedString(string: self.currentPrice, attributes: [
                                              .foregroundColor: UIColor(white: 26.0 / 255.0, alpha: 1.0),
                                              .kern: -1.92
                                            ])

                                            attributedString.addAttributes([
                                              .foregroundColor: UIColor(red: 0.0, green: 126.0 / 255.0, blue: 1.0, alpha: 1.0)
                                            ], range: NSRange(location: 0, length: self.currentPrice.count))

                                            self.lblCurrentPrice.attributedText = attributedString
                                            
                                            self.nextResetPrice = true
                                        }
                                    }
                                case false:
                                    break
                                }
                            }
                        }
                        if batchSelection && ableBidding() {
                            batchBidMode = true
                            setupBatchBid(batchSelection: batchSelection, batchBidMode: batchBidMode)
                        }
                        if batchSelection && batchBidMode {
                            // 응찰금액을
                            let screenAction2 = screenAction(statusCode: 120001)
                            runScreenAction(screenAction: screenAction2)
                        }
                        if globalCurrentEntryInfo.objIdNum != currentEntryInfo?.objIdNum {
                            currentPrice = "0"
                            lblCurrentPrice.text = currentPrice
                            lblCurrentPrice.textColor = .black
                        }
                        globalCurrentEntryInfo = currentEntryInfo!
                        globalCurrentTransaction = transaction
                        entryNum = currentEntryInfo!.entryNum
                        let result: (Bool, [String]) = actCurrentEntryInfo(currentEntryInfo: currentEntryInfo!)
                        if result.0 == true {

                            lblEntryText1.text = ""
                            lblEntryText2.text = ""
                            lblEntryText3.text = ""
                            lblEntryText4.text = ""
                            lblEntryText5.text = ""
                            lblEntryText6.text = ""
                            lblEntryText7.text = ""
                            lblEntryText8.text = ""
                            lblEntryText9.text = ""
                            lblEntryText10.text = ""

                            for (index, elem) in result.1.enumerated() {

                                switch index {
                                case 0:
                                    lblEntryText1.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader1, text: lblEntryText1)
                                case 1:
                                    lblEntryText2.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader2, text: lblEntryText2)
                                case 2:
                                    lblEntryText3.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader3, text: lblEntryText3)
                                case 3:
                                    lblEntryText4.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader4, text: lblEntryText4)
                                case 4:
                                    lblEntryText5.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader5, text: lblEntryText5)
                                case 5:
                                    lblEntryText6.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader6, text: lblEntryText6)
                                case 6:
                                    lblEntryText7.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader7, text: lblEntryText7)
                                case 7:
                                    lblEntryText8.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader8, text: lblEntryText8)
                                case 8:
                                    lblEntryText9.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader9, text: lblEntryText9)
                                case 9:
                                    lblEntryText10.text = elem
                                    setEntryLabelHeaderTextAndValue(header: lblEntryHeader10, text: lblEntryText10)
                                default:
                                    break
                                }
                            }
                        }
                        
                        if isFirstEntry == true {
                            currentLowPrice = globalCurrentEntryInfo.lowPrice
                            actCallFavorite( naBzPlc: globalCurrentEntryInfo.auctionHouseCode,  aucClass: globalCurrentEntryInfo.entryType , userMemNum: LocalStorage.shared.getTraderMngNum() , aucSeq: globalCurrentEntryInfo.entryNum )
                        }
                        isFirstEntry = false
                        break

                    case SOCKET_PROTOCOL_CODE.AUCTION_STATE:
                        let auctionStatus = AuctionStatus.init(transaction: transaction)
                        var screenAction2 = screenAction(statusCode: 160000 + auctionStatus!.status)
                        
                        if (batchSelection) == true {
                            if (auctionStatus!.status == 8006) {
                                screenAction2 = screenAction(statusCode: 160002 + auctionStatus!.status)
                            } else {
                                screenAction2 = screenAction(statusCode: 160000 + auctionStatus!.status)
                            }
                        } else {
                            screenAction2 = screenAction(statusCode: 160000 + auctionStatus!.status)
                        }
                        
                        if auctionStatus!.status == 8003 || auctionStatus!.status == 8004 {
                            statusAbleBidding = true
                        } else {
                            statusAbleBidding = false
                        }

                        if auctionStatus!.status == 8002
                            || auctionStatus!.status == 8003
                            || auctionStatus!.status == 8004
                            || auctionStatus!.status == 8006 {
                            currentPrice = "0"
                            
                            lblCurrentPrice.text = currentPrice
                            lblCurrentPrice.textColor = .black
                        }
                        //TODO 8004는 테스트코드
                        
                        // 관전모드가 아닌 경우 일괄 단일 둘다 표시
                        if !isObserverMode {
                            if auctionStatus!.status == 8002
                                || auctionStatus!.status == 8006 {
                                
                                let greenLabel = self.view.viewWithTag(LABEL_TAG.GREEN_LABEL)
                                let redLabel = self.view.viewWithTag(LABEL_TAG.RED_LABEL)
                                
                                
                                if (batchSelection) == true {
                                    if (auctionStatus!.status == 8006) {
                                        if redLabel == nil {
                                                // 일괄 경매 모드일 경우 경매 종료 시 경매 종료 상태 문구 표시되도록 변경 2021.12.29 jspark
                                            self.showToastNHBigColorRed(string: "경매가 종료되었습니다.", redStart: 4, redLength: 2, yPos: Int(bidView.frame.origin.y + statusView.frame.height))
                                        }
                                    } else {
                                        if greenLabel == nil {
                                            
                                            if redLabel != nil {
                                                redLabel?.removeFromSuperview()
                                            }
                                            
                                                // Big Toast View 위치 상태바 하단에 위치하도록 변경 적용 2021.12.22 jspark
                                            self.showToastNHBigColorGreen(string: "경매 대기 중입니다.", greenStart: 3, greenLength: 4, yPos: Int(bidView.frame.origin.y + statusView.frame.height))
                                        }
                                    }
                                } else {
                                    if greenLabel == nil {
                                        
                                            // Big Toast View 위치 상태바 하단에 위치하도록 변경 적용 2021.12.22 jspark
                                        self.showToastNHBigColorGreen(string: "경매 대기 중입니다.", greenStart: 3, greenLength: 4, yPos: Int(bidView.frame.origin.y + statusView.frame.height))
                                    }
                                }
                                
                            } else {
                                let greenLabel = self.view.viewWithTag(LABEL_TAG.GREEN_LABEL)
                                greenLabel?.removeFromSuperview()
                                
                                let redLabel = self.view.viewWithTag(LABEL_TAG.RED_LABEL)
                                redLabel?.removeFromSuperview()
                            }
                        }
                        
                        if auctionStatus!.status == 8001
                            || auctionStatus!.status == 8007{
                            runScreenAction(screenAction: screenAction2)
                        }
                        
                        runScreenAction(screenAction:screenAction2)
                        
                        if batchSelection && auctionStatus!.status == 8002 {
                            topValueShow = false
                            showHideTopValue()
                        }
                        if auctionStatus!.status == 8004 {
                            
                            
                            if batchSelection {
                                topValueShow = true
                                showHideTopValue()
                                batchBidMode = false
                                if (batchSelection && !batchBidMode) {
                                    
                                    let screenAction3 = screenAction(statusCode: 168104)
                                    
                                    runScreenAction(screenAction: screenAction3)
                                    currentPrice = "0"
                                    lblCurrentPrice.textColor = .black
                                    lblCurrentPrice.text = currentPrice
                                    currentBatchEntryNum = "0"
                                    batchEntryNum.text = "0"
                                    if currentBatchEntryNum == "0" {
                                        batchEntryNum.isHidden = true
                                    } else {
                                        batchEntryNum.isHidden = false
                                    }
                                        
                                    setupBatchBid(batchSelection: batchSelection, batchBidMode: batchBidMode)
                                }
                            } else {
                                let screenAction3 = screenAction(statusCode: 168004)
                                runScreenAction(screenAction: screenAction3)
                                if globalCurrentEntryInfo.entryNum != "" {
                                
                                    currentLowPrice = globalCurrentEntryInfo.lowPrice
                                    actCallFavorite( naBzPlc: globalCurrentEntryInfo.auctionHouseCode,  aucClass: globalCurrentEntryInfo.entryType , userMemNum: LocalStorage.shared.getTraderMngNum() , aucSeq: globalCurrentEntryInfo.entryNum )
                                } else {
                                    debugPrint("#1571: globalCurrentEntryInfo is null")
                                }
                            }
                        }
                        break
                    case SOCKET_PROTOCOL_CODE.RETRY_TARGET_INFO:

                        retryStatus = true
                        let retryTargetInfo = RetryTargetInfo.init(transaction: transaction)

                        let screenAction = screenAction(statusCode: 320000, message: retryTargetInfo!.retryBidders)
                        runScreenAction(screenAction: screenAction)
                        if screenAction.extraBool == true {
                            retryTrue = true
                        }
                        if screenAction.extraBool == false {
                            retryFalse = true
                        }
                        break
                    default:
                        debugPrint("undefined message\(transaction)")
                        break
                    }
                }
            }
        }
    }
    
    func setEntryLabelHeaderTextAndValue(header headerLabel: UILabel, text entryTextLabel: MarqueeLabel) {
        if headerLabel.text == "비고" && entryTextLabel.willBeTruncated(){
            setMarquee(elem: entryTextLabel, isOn: true)
        } else {
            setMarquee(elem: entryTextLabel, isOn:  false)
        }
        
        if headerLabel.text == "출하주" {
            entryTextLabel.lineBreakMode = .byTruncatingHead
        } else {
            entryTextLabel.lineBreakMode = .byTruncatingTail
        }
        
        if headerLabel.text == "최저가", let isComma = entryTextLabel.text?.contains(","), !isComma, entryTextLabel.text != "-"  {
            if let price = entryTextLabel.text, !price.isEmpty, let intPrice = Int(price), intPrice > 0 {
                entryTextLabel.text = intPrice.withCommas()
            }
        }
    }
    
    func startCheckSessionTimer() {
        debugPrint("Run startCheckSessionTimer")
        
        if (scheduleTimer != nil) {
            scheduleTimer.invalidate()
            scheduleTimer = nil
        }
        scheduleTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(checkSession), userInfo: nil, repeats: false)
    }
    
    @objc func checkSession()
    {
        debugPrint("Check server session connect")
        
        socketDisconnected()
    }

    /***
     즐겨찾기 호출하는 action
     - Parameters:
      - naBzPlc: auctionHouseCode
       - aucClass: entryType
       - userMemNum: getTraderMngNum
       - aucSeq: entryNum
     */
    func  actCallFavorite( naBzPlc: String, aucClass: String, userMemNum: String, aucSeq: String ) {
        // 관전모드의 경우 찜가격 조회 API를 호출하지 않는다.
        guard !isObserverMode else { return }
        
        callFavorite( naBzPlc: globalCurrentEntryInfo.auctionHouseCode,  aucClass: globalCurrentEntryInfo.entryType , userMemNum: userMemNum , aucSeq: globalCurrentEntryInfo.entryNum )
        {
            result in
            let favorite = result.value!
            
            switch favorite.success {
                
            case true:
                let favPrice: Int = favorite.info?.SBID_UPR ?? 0
                
                let text = "\(favPrice.withCommas())"
                self.lblCurrentPrice.text = text
                self.lblCurrentPrice.textColor = UIColor(hexString: "#007EFF")

                let attributedString : NSMutableAttributedString = NSMutableAttributedString(string: String(favPrice), attributes: [
                    .font: UIFont(name: FONT.APP_MEDIUM, size: 30)!,
                    .foregroundColor: UIColor(white: 26.0 / 255.0, alpha: 1.0),
                    .kern: -1.92
                ])
                
                attributedString.addAttributes([
                    .font: UIFont(name: FONT.APP_BOLD, size: 55.0)!,
                    .foregroundColor: UIColor(red: 0.0, green: 126.0 / 255.0, blue: 1.0, alpha: 1.0)
                ], range: NSRange(location: 0, length: String(favPrice).count))
                
                self.currentPrice = String(favPrice)
                self.lblCurrentPrice.attributedText = attributedString
                self.nextResetPrice = true
                break
            case false:
                break
            }
        }
    }

    /***
     흐르는 문자 이벤트 설정
     - Parameters:
       - elem: Element
       - isOn: onOff 설정
     */
    func setMarquee(elem: MarqueeLabel, isOn: Bool) {
        if isOn == true {
            elem.text = "\(elem.text!)   "
            elem.type = .continuous
            elem.speed = .duration(4)
            elem.labelize = false
        } else {
            elem.labelize = true
        }
    }

    /***
     입찰 동작
     */
    func actBidding() {
        let tokenString = LocalStorage.shared.getUserToken()
        
        do {
            let jwt = try decode(jwt: tokenString)

            let bidding: Bidding = Bidding()
            bidding.type = SOCKET_PROTOCOL_CODE.BIDDING
            bidding.auctionHouseCode = jwt.auctionHouseCode!
            bidding.osType = SOCKET_COMMON.CONNECTION_CHANNEL_NAME
            bidding.traderMngNum = jwt.userMemNum!
            bidding.userNum = LocalStorage.shared.getUserNum()
            bidding.entryNum = entryNum
            bidding.price = Int(currentPrice)!

            if (biddedDic[globalCurrentEntryInfo.objIdNum] != nil ){
                bidding.newBiddingYn = "N"
            } else {
                bidding.newBiddingYn = "Y"
            }
            
            biddedDic[globalCurrentEntryInfo.objIdNum] = globalCurrentEntryInfo.objIdNum
            
            bidding.time = Int(getTodayDate(format: "yyyyMMddHHmmssSSS"))!

            do {
                try _ = self.write(bidding.toString())
            } catch {
                debugPrint(error)
            }

        } catch {

        }
    }
    
    /***
     일괄경매의 RequestEntryInfo
     - Parameter entryNum:
     */
    func actRequestEntryInfo(entryNum: String) {

        let tokenString = LocalStorage.shared.getUserToken()
        do {
            let jwt = try decode(jwt: tokenString)
            let requestEntryInfo: RequestEntryInfo = RequestEntryInfo()
            requestEntryInfo.type = SOCKET_PROTOCOL_CODE.REQUEST_ENTRY_INFO
            requestEntryInfo.auctionHouseCode = jwt.auctionHouseCode!
            requestEntryInfo.traderMngNum = jwt.userMemNum!
            requestEntryInfo.entryNum = entryNum

            do {
                try _ = self.write(requestEntryInfo.toString())
            } catch {
                debugPrint(error)
            }

        } catch {

        }
    }
    /***
     RequestBiddingInfo
     */
    func actRequestBiddingInfo() {

        let tokenString = LocalStorage.shared.getUserToken()
        do {
            let jwt = try decode(jwt: tokenString)
            let requestBiddingInfo: RequestBiddingInfo = RequestBiddingInfo()
            requestBiddingInfo.type = SOCKET_PROTOCOL_CODE.REQUEST_BIDDING_INFO
            requestBiddingInfo.auctionHouseCode = jwt.auctionHouseCode!
            requestBiddingInfo.traderMngNum = jwt.userMemNum!
            requestBiddingInfo.entryNum = entryNum
            requestBiddingInfo.userNum = LocalStorage.shared.getUserNum()

            do {
                try _ = self.write(requestBiddingInfo.toString())
            } catch {
                debugPrint(error)
            }

        } catch {

        }
    }

    /***
     입찰 취소
     */
    func actCancelBidding() {

        let tokenString = LocalStorage.shared.getUserToken()
        do {
            let jwt = try decode(jwt: tokenString)

            let cancelBidding: CancelBidding = CancelBidding.init()
            cancelBidding.type = SOCKET_PROTOCOL_CODE.CANCEL_BIDDiNG
            cancelBidding.auctionHouseCode = jwt.auctionHouseCode!
            cancelBidding.entryNum = entryNum
            cancelBidding.userNum = LocalStorage.shared.getUserNum()
            cancelBidding.traderMngNum = jwt.userMemNum!
            cancelBidding.osType = SOCKET_COMMON.CONNECTION_CHANNEL_NAME
            cancelBidding.time = Int(getTodayDate(format: "yyyyMMddHHmmssSSS"))!

            do {
                try _ = self.write(cancelBidding.toString())
            } catch {
                debugPrint(error)
            }
        } catch {

        }
    }

    /***
     설정된 값에 따라 화면에 이벤트를 실행하는 method
     - Parameter screenAction: 각종타입의 설정값
     */
    func runScreenAction(screenAction: ScreenAction) {
        switch screenAction.type {
        case SCREEN_ACTION_TYPE.TOAST_MESSAGE:
            self.showToastNH(text: screenAction.toastMessage)
        case SCREEN_ACTION_TYPE.STATUS_STRING:
            self.lblAuctionState.attributedText = screenAction.attributedString
            if screenAction.attributedString.string == "" {
                debugPrint("#1778:\(screenAction.attributedString)")
            }
        case SCREEN_ACTION_TYPE.TOAST_MESSAGE_BIG:
            if !isObserverMode {
                // 응찰 완료 시 응찰되었습니다. 문구 고정 처리되도록 변경 적용 2021.12.22 jspark
                //            screenAction.attributedString = NSMutableAttributedString(string: screenAction.toastMessageBig)
                self.lblAuctionState.attributedText = screenAction.attributedString
                
                    // Big Toast View 위치 상태바 하단에 위치하도록 변경 적용 2021.12.22 jspark
                self.showToastNHBig(text: screenAction.toastMessageBig, yPos: Int(bidView.frame.origin.y + statusView.frame.height))
            }
        case SCREEN_ACTION_TYPE.STATUS_TOAST:
            if !isObserverMode {
                self.lblAuctionState.isHidden = true
                self.lblStatusToast.attributedText = screenAction.statusToast
                self.lblStatusToast.isHidden = false
                _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
                    UIView.transition(with: self.view, duration: 0.5,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        self.lblStatusToast.text = ""
                        self.lblStatusToast.isHidden = true
                        self.lblAuctionState.isHidden = false
                    })
                })
            }
        case SCREEN_ACTION_TYPE.FORCE_BACK_STRING:
            self.popupOneBtn(withTitle: TEXT.NOTICE, msg: screenAction.forceBackString, buttonAction: {
                //23.03.21 관전을 종료하고 메인화면으로 이동해도 관전 Voice 가 play 되는 이슈 대응
                //NHWebViewController에서 처리되야할 142002 "이미지접속한사용자가있습니다"메시지가 여기서도 뜰때도 있음.
                //사운드가 디폴트값이 펄스라 들어가자마자 메시지창 나오고 화면제어가 불가능하기 때문에 여기서 사운드를 끌 필요는 없다고 판단되지만 로직은 작성함. 
                if self.agoraEngine != nil {
                    self.leaveChannel()
                }
                self.inputStream?.close()
                self.outputStream?.close()
                self.pop(animated: true)
            })
            break
        case SCREEN_ACTION_TYPE.FORCE_BACK_ATTR:
            self.popupOneBtn(withTitle: TEXT.NOTICE, msgAttr: screenAction.attributedString, buttonAction: {
                //23.03.21 관전을 종료하고 메인화면으로 이동해도 관전 Voice 가 play 되는 이슈 대응 PC진행프로그램에서 회차종료했을 경우
                if self.agoraEngine != nil {
                    self.leaveChannel()
                }
                self.inputStream?.close()
                self.outputStream?.close()
                self.pop(animated: true)
            })
            break
        case SCREEN_ACTION_TYPE.ONE_BUTTON:
            self.popupOneBtn(withTitle: TEXT.NOTICE, msg: screenAction.oneButtonString, buttonAction: {
            })
            break
        default:
            break
        }
    }
    
    /***
     접속이 끊어졌을때 동작하는 event
     */
    func socketDisconnected() {
        debugPrint("disconnected")
        status = SOCKET_STATUS.DISCONNECTED

            if ( !popupOpened) {
                popupOpened = true
                
                if isObserverMode {
                    self.popupOneBtn(withTitle: TEXT.NOTICE, msg: "네트워크 연결 상태가 불안정합니다.\n네트워크 상태를 확인해주세요.", buttonTitle: "나가기") {
                        //23.03.21 관전을 종료하고 메인화면으로 이동해도 관전 Voice 가 play 되는 이슈 대응 관전모드에서 소켓연결이 끊어졌을때
                        if self.agoraEngine != nil {
                            self.leaveChannel()
                        }
                        self.inputStream?.close()
                        self.outputStream?.close()
                        self.pop(animated: true)
                    }
                } else {
                    self.popupTwoBtn(msg: "네트워크 상태가 불안정합니다.\n재접속하시겠습니까?" , rightTitle: "재접속", leftBtnAction: {
                        //23.03.21 관전을 종료하고 메인화면으로 이동해도 관전 Voice 가 play 되는 이슈 대응 응찰모드에서 소켓연결이 끊어졌을때
                        if self.agoraEngine != nil {
                            self.leaveChannel()
                        }
                        self.inputStream?.close()
                        self.outputStream?.close()
                        self.pop(animated: true)
                    }, rightBtnAction: {
                        let sockethost = LocalStorage.shared.getNetHost()
                        let socketPort = LocalStorage.shared.getNetPort()
#if DEBUG
                            //                        sockethost = SOCKET.DEBUG_HOST
#endif
                        self.connect(host: sockethost, port: Int(socketPort)!)
                        self.status = SOCKET_STATUS.DISCONNECTED
                        self.popupOpened = false
                    })
                }
            }
    }

    /***
     각종 화면설정하는 event
     */
    func setUpView() {
        let isBatchSelection = LocalStorage.shared.getIsBatchSelection()
        setupBatchBid(batchSelection: isBatchSelection, batchBidMode: false)
        
        entryView.layer.borderColor = UIColor.init(hexString: COLOR.RGB_007EFF).cgColor
        entryView.layer.borderWidth  = 2.0
        pageControl.isEnabled = false
        pageControl.currentPage = 0
        pageControl.numberOfPages = self.CHANNELS.count
        pageControl.pageIndicatorTintColor = UIColor.init(hexString: COLOR.RGB_DBDBDB) // 페이지를 암시하는 동그란 점의 색상
        pageControl.currentPageIndicatorTintColor = UIColor.init(hexString: COLOR.RGB_007EFF)  // 현재 페이지를 암시하는 동그란 점 색상
        
        if let attributedString = STATUS_VIEW.init(string: "경매 대기 중입니다.", blueStart: 3, blueLength: 4)?.attrString {
            self.lblAuctionState.attributedText = attributedString
        }
        if pageControl.currentPage != 0 {
            pageControl.isHidden = false
        } else {
            pageControl.isHidden = true
        }
        
        
        for elem in ENTRY_HEADER.DEFAULT {
            
            LocalStorage.shared.setEntryHeaderIndex(headerListIndex: ["1", // 출품번호
                                                                      "3", // 성별
                                                                      "2", // 출하주
                                                                      "4", // 중량
                                                                      "7", // 산차
                                                                      "5", // 어미
                                                                      "6", // 계대
                                                                      "8", // KPN
                                                                      "11", // 최저가
                                                                      "10" // 비고
                                                                     ])
            
            let pos = ENTRY_HEADER.DEFAULT.firstIndex(of: elem)
            switch pos {
            case 0:
                lblEntryHeader1.text = elem
            case 1:
                lblEntryHeader2.text = elem
            case 2:
                lblEntryHeader3.text = elem
            case 3:
                lblEntryHeader4.text = elem
            case 4:
                lblEntryHeader5.text = elem
            case 5:
                lblEntryHeader6.text = elem
            case 6:
                lblEntryHeader7.text = elem
            case 7:
                lblEntryHeader8.text = elem
            case 8:
                lblEntryHeader9.text = elem
            case 9:
                lblEntryHeader10.text = elem
                
            default:
                break
            }
            
        }
        
        // 22.04.27 ver 1.0.5 update
        // btnBackArrow 이미지 삭제 > "지움" Text로 변경
        //btnBackArrow.imageView?.contentMode = .scaleAspectFit

        let topViewHeight = topView.frame.height
        let scrollViewHeight = scrollView.frame.height
        let statusViewHeight = statusView.frame.height
        let priceViewHeight = priceView.frame.height
        
        let mainviewHeight = UIScreen.main.bounds.height
        let mainViewWidth = UIScreen.main.bounds.width

        let keypadViewHeight = mainviewHeight
        - ( topViewHeight + scrollViewHeight + statusViewHeight + priceViewHeight )
        
        debugPrint("#1575:\(mainviewHeight):\(topViewHeight) : \(scrollViewHeight) : \(statusViewHeight) : \(priceViewHeight)")
        let isNotch = hasTopNotch
        let notchSize = sizeTopNotch
        var notchMargin = 0.0
        if isNotch {
            notchMargin = Double(notchSize)
        } else {
            if mainviewHeight > 700 {
                notchMargin = 20.0
            } else {
                notchMargin = 0.0
            }
        }

        //기기에 맞게 스크롤뷰의 비율을 재조정함.
        self.scrollViewAspect.setMultiplier(multiplier: self.scrollView.frame.width / self.scrollView.frame.height)
        constraint7Height.constant = (keypadViewHeight - 50 - notchMargin) / 4
        constraint7Width.constant = (mainViewWidth - 45 ) / 4
        
        view.layoutIfNeeded()
    }
    
    
    /***
     동영상영역이 터치되었을때 실행되는 method
     - Parameter sender:
     */
    @objc func checkAction(sender : UITapGestureRecognizer) {
        
        if currentCastPaused {
            agoraEngine.enableVideo()
        }
        debugPrint("#checkAction is touched")
    }

    /***
     일괄경매의 이전화면 버튼 터치시실행
     - Parameter sender:
     */
    @IBAction func btnBatchPrevTouched(_ sender: Any) {
        if batchSelection && batchBidMode {
            batchBidMode = false
            setupBatchBid(batchSelection: batchSelection, batchBidMode: batchBidMode)
            currentBatchEntryNum = "0"
            
            batchEntryNum.text = currentBatchEntryNum
            
            currentPrice = "0"
            if currentBatchEntryNum == "0" {
                batchEntryNum.isHidden = true
            } else {
                batchEntryNum.isHidden = false
            }
            lblCurrentPrice.text = currentPrice
            lblCurrentPrice.textColor = .black
            if batchSelection && !batchBidMode{
                let screenAction2 = screenAction(statusCode: 201001)
                runScreenAction(screenAction:screenAction2)
            }
        }
    }

    /***
     몇번째 위치에 어떤 채널을 화면에 표시할지 지정
     - Parameters:
       - position: 몇번째 페이지에
       - channelId: 어떤 채널을
     */
    func setCast(position: NSInteger, channelId: String) {
        if self.agoraEngine == nil {
            self.agoraEngine = AgoraRtcEngineKit()
        } else {
            leaveChannel()
            self.agoraEngine = AgoraRtcEngineKit()
        }
        
        // engine 객체를 새로 생성했으니 설정도 새로 해야 함
        initializeAgoraEngine()

        // view 설정
        remoteView1 = UIView(frame: CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: scrollView.frame.height))
        remoteView1.tag = VIEW_TAG.REMOTE_VIEW_TAG_BASE + position
        toChID = channelId
        let subView1 = view.viewWithTag(VIEW_TAG.SUB_VIEW_TAG_BASE + position - 1 )! as UIView

        subView1.addSubview(remoteView1)
        
        self.remoteView1.center.x = self.scrollView.bounds.width / 2
        self.setLocalStorageSpeakerOnOff()
        joinChannel()
    }
    
    //화면 회전시의 영향인지 영상이 빠릿하게 잘 안나오는것 같은데 동영상 터치시 실행되는 함수가 있으니 잘안나온다 싶으면 영상터치해볼것
    @IBAction func buttonRotate(_ sender: Any) {
        debugPrint("### buttonRotate")
        var value = UIInterfaceOrientation.landscapeRight.rawValue
        
        if UIApplication.shared.statusBarOrientation == .landscapeRight{
            value = UIInterfaceOrientation.portrait.rawValue
            self.checkSceneRotate = false;
            appDelegate.shouldSupportAllOrientation = false
        }  else {
            self.checkSceneRotate = true;
            appDelegate.shouldSupportAllOrientation = true
        }
        UIDevice.current.setValue(value, forKey: "orientation")
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
            
            if (value == UIInterfaceOrientation.landscapeRight.rawValue) {
                OperationQueue.main.addOperation {
                    self.scrollView.layoutIfNeeded()
                    self.horizontalScreen();
                }
            } else {
                OperationQueue.main.addOperation {
                    self.scrollView.layoutIfNeeded()
                    self.verticalScreen();
                }
            }
        }
    }
    
    func horizontalScreen () {
        debugPrint("### horizontalScreen")
        self.fullScreenBt.setImage(UIImage(named:"ic_fullscreen_exit.png"), for: UIControl.State.normal)
        NSLayoutConstraint.activate([self.svScreenBottomConst])
    }
    
    func verticalScreen() {
        debugPrint("### verticalScreen")
        self.fullScreenBt.setImage(UIImage(named:"ic_fullscreen_exit.png"), for: UIControl.State.normal)
       NSLayoutConstraint.deactivate([self.svScreenBottomConst])
    }

    /***
     LocalStorage.shared.getIsSpeakerOnOff() 값으로 Audio 설정
     */
    func setLocalStorageSpeakerOnOff() {
        let speakerOnOff : Bool = LocalStorage.shared.getIsSpeakerOnOff()
        if speakerOnOff == true {
            btnSpeakerOnOff.isSelected = true
            setMute(input: false)
        } else {
            btnSpeakerOnOff.isSelected = false
            setMute(input: true)
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //뷰가 회전한것을 체크. 
        self.isViewWillTransition.toggle()
        //화면 회전시 스크롤뷰의 영상화면 삭제후 다시 추가
        for index in self.remoteViewWithTagValue {
            if let subView = self.view.viewWithTag(index) {
                subView.removeFromSuperview()
            }
        }
        //23.02.07 화면회전 셋팅 및 회전 후 페이징스크롤 처리
        coordinator.animate (alongsideTransition: {_ in
            self.agoraConnect(firstCall: true)
            if (self.checkSceneRotate == true) {
                self.view.backgroundColor = UIColor.black
                self.fullScreenBt.setImage(UIImage(named:"ic_fullscreen_exit.png"), for: UIControl.State.normal)
                NSLayoutConstraint.activate([self.svScreenBottomConst])
                self.view.layoutIfNeeded()
            } else {
                self.view.backgroundColor = UIColor.white
                self.fullScreenBt.setImage(UIImage(named:"ic_fullscreen.png"), for: UIControl.State.normal)
                NSLayoutConstraint.deactivate([self.svScreenBottomConst])
                self.view.layoutIfNeeded()
            }
        },completion: {_ in
            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.width * CGFloat(self.onlyUseHorizenModeCurrentPageValue), y: 0.0), animated: false)
            self.scrollView.layoutIfNeeded()
        })
    }
}

extension JWT {
    var userRole: String? {
        return claim(name: "userRole").string
    }
    var userMemNum: String? {
        return claim(name: "userMemNum").string
    }
    var auctionHouseCode: String? {
        return claim(name: "auctionHouseCode").string
    }
}

extension RealtimeViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width);

        if currentPage > 0 {
            pageControl.currentPage = currentPage - 1
        }
    }
    /***
     이동될 페이지 설정
     - Parameter scrollView:
     */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.remonFirstClose = true
        if decelerate == false && currentPage != Int(scrollView.contentOffset.x / scrollView.frame.size.width){
            // Do something with your page update
            
            currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            debugPrint("scrollViewDidEndDragging: \(currentPage)")
            setPageControlSelectedPage(currentPage: currentPage)
        }
    }
    /***
     이동될 페이지 설정
     - Parameter scrollView:
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.onlyUseHorizenModeCurrentPageValue = currentPage
        self.onlyUseHorizenModeScrollViewOffsetX = scrollView.contentOffset.x;
        self.remonFirstClose = true
        // Do something with your page update
            currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            debugPrint("scrollViewDidEndDecelerating: \(currentPage)")
        
        if oldPage != currentPage   {
            setPageControlSelectedPage(currentPage: currentPage)
        }
    }


    /***
     페이지 콘트롤이 몇번째 페이지로 이동하는지 설정
     - Parameter currentPage: 이동될 페이지
     */
    private func setPageControlSelectedPage(currentPage: Int) {

        pageControl.currentPage = currentPage - 1
        
        if (currentPage == 0) {
            btnPrevPage.isHidden = true
        } else {
            btnPrevPage.isHidden = false
        }
        
        if (currentPage == totalPage-1) {
            btnNextPage.isHidden = true
        } else {
            btnNextPage.isHidden = false
        }
        
        if (self.CHANNELS.count > 0) {
            hideAndShowCast(oldPage: oldPage, currentPage: currentPage, isSpeakerOn: LocalStorage.shared.getIsSpeakerOnOff())
        }
        oldPage = currentPage
        
        if currentPage != 0 {
            pageControl.isHidden = false
        } else {
            pageControl.isHidden = true
        }
        
    }
    
    
    /***
     실시간 방송을 보여주고 숨기는 method
     - Parameters:
       - oldPage: 예전페이지
       - currentPage: 신규이동될 페이지
       - isSpeakerOn: 스피커 onOff여부
     */
    private func hideAndShowCast(oldPage : Int, currentPage : Int, isSpeakerOn : Bool) {

        var playNew:Bool = false
        var playDelete: Bool = false
        var castNew:Int = 0
        var castDelete:Int = 0
        
        if currentPage == 0 {
            if oldPage == 0 {
                oldCastPage = 1
                debugPrint(" 삭제할 동영상 없음 : 처음 시작 ")
                debugPrint(" 위치는 0이지만 1페이지 동영상 플레이 : castPage:\(oldCastPage)")
                playDelete = false
                if isSpeakerOn {
                    playNew = true
                    castNew = 1
                } else {
                    playNew = false
                    castNew = 0
                }
            } else if oldPage == 1{
                oldCastPage = 1
                debugPrint(" 삭제할 동영상 없음 ")
                debugPrint(" 위치는 0이지만 1페이지 동영상 그대로 유지   : castPage:\(oldCastPage)")
                playDelete = false
                playNew = false
                if isSpeakerOn {
                    playDelete = false
                } else {
                    playDelete = true
                    castDelete = oldCastPage
                }
            } else {
                debugPrint(" 삭제할 동영상 \(oldCastPage) ")
                playDelete = true
                playNew = false
                
                castDelete = oldCastPage
                castNew = 1
                oldCastPage = 1
                debugPrint(" 위치는 0이지만 1페이지 추가재생    : castPage:\(oldCastPage)")
            }
        } else {
            
            if oldPage == 0 && currentPage == 1 {
                oldCastPage = 1
                debugPrint(" 삭제할 동영상 없음 \(currentReadyDelete)")
                playDelete = false
                if isSpeakerOn && (currentReadyDelete == 1){
                    playNew = false
                    castNew = 0
                    debugPrint(" 위치는 1이고  1페이지 동영상 플레이 그대로 유지  : castPage:\(oldCastPage)")
                } else if isSpeakerOn && (currentReadyDelete != 1){
                    playNew = true
                    castNew = 1
                    debugPrint(" 위치는 1이고  1페이지 동영상 플레이 #1")
                } else {
                    playNew = true
                    castNew = 1
                    debugPrint(" 위치는 1이고  1페이지 동영상 신규 플레이 #2")
                }
            } else if oldPage == 0 && currentPage > 1 {
                oldCastPage = currentPage
                debugPrint(" 삭제할 1 동영상 ")
                debugPrint(" 위치는 \(currentPage)이고  1페이지 동영상 플레이 삭제   : castPage:\(oldCastPage)")
                playDelete = true
                playNew = true
                
                castDelete = 1
                castNew = currentPage
            } else if oldPage == currentPage {
                oldCastPage = currentPage
                debugPrint(" 위치는 \(currentPage)이고  ehdehddlf   : castPage:\(oldCastPage)")
//                playDelete = true
                playNew = true
                
                castDelete = currentPage
                castNew = currentPage
            } else {
                playDelete = true
                playNew = true
                
                castDelete = oldCastPage
                castNew = currentPage
                
                debugPrint(" \(oldCastPage)플레이중인것 삭제하고 새로 \(currentPage) 페이지 플레이  : castPage:\(currentPage)")
                oldCastPage = currentPage
            }
        }

        if playDelete {
            //기존 view를 삭제
            addReadyToCast(position:castDelete)
            self.leaveChannel()
            currentReadyDelete = castDelete
        }
        
        if playNew && self.CHANNELS.count >= castNew {
            debugPrint("new =>\(castNew)")
            addReadyToCast(position:castNew)
            currentReadyDelete = castNew
            let selectedChannelId :String = self.CHANNELS[castNew-1]
            if selectedChannelId != "" {
                setCast(position:castNew, channelId:selectedChannelId)
                self.selectedChannelIdTmp = selectedChannelId
            } else {
                
                if self.remonFirstClose {
                    agoraConnect(firstCall: false)
                    self.remonFirstClose = false
                }
            }
 
        }
    }
}

extension RealtimeViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("message.name:\(message.name)");
        debugPrint("message.body:\(message.body)");
        switch message.name {
        case "setCowInfo":
            // 일괄 경매의 관전 모드에서 화면 하단 웹뷰의 경매 목록 중 하나 선택하면 해당 스크립트로 정보를 받아와
            // 화면에 표시한다.
            if let messageBody = message.body as? String {
                let arrMag = messageBody.components(separatedBy: "|")
                let currentEntryInfo = CurrentEntryInfo.init()
                for i in 0...arrMag.count {
                    if i == 0, i < arrMag.count { currentEntryInfo.entryNum = arrMag[i] } // 번호
                    if i == 1, i < arrMag.count { currentEntryInfo.entryGender = arrMag[i] } // 성별
                    if i == 2, i < arrMag.count { currentEntryInfo.exhibitor = arrMag[i] } // 출하주
                    if i == 3, i < arrMag.count { currentEntryInfo.weight = arrMag[i] } // 중량
                    if i == 4, i < arrMag.count { currentEntryInfo.cavingNum = Int(arrMag[i]) ?? 0 } // 산차
                    if i == 5, i < arrMag.count { currentEntryInfo.motherTypeCode = arrMag[i] } // 어미
                    if i == 6, i < arrMag.count { currentEntryInfo.pasgQcn = arrMag[i] } // 계대
                    if i == 7, i < arrMag.count { currentEntryInfo.entryKpn = arrMag[i] } // KPN
                    if i == 8, i < arrMag.count { currentEntryInfo.lowPrice = Int(arrMag[i]) ?? 0 } // 최저가
                    if i == 9, i < arrMag.count { currentEntryInfo.note = arrMag[i] } // 비고
                }
                let result: (Bool, [String]) = actCurrentEntryInfo(currentEntryInfo: currentEntryInfo)
                if result.0 == true {
                    topValueShow = true
                    showHideTopValue()
                    
                    lblEntryText1.text = ""
                    lblEntryText2.text = ""
                    lblEntryText3.text = ""
                    lblEntryText4.text = ""
                    lblEntryText5.text = ""
                    lblEntryText6.text = ""
                    lblEntryText7.text = ""
                    lblEntryText8.text = ""
                    lblEntryText9.text = ""
                    lblEntryText10.text = ""
                    for (index, elem) in result.1.enumerated() {
                        var elemValue = elem
                        // 값이 null인 경우 "-"로 표시한다.
                        // 최저가가 아닌 Int 값이 "0"인 경우 "-"로 표시한다.
                        if elem == "" || (elem == "0" && !(index == 8)) {
                            elemValue = "-"
                            // 중량은 값이 없는 경우 "0"으로 표시한다.
                            if index == 3 {
                                elemValue = "0"
                            }
                        }
                        switch index {
                        case 0:
                            lblEntryText1.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader1, text: lblEntryText1)
                        case 1:
                            lblEntryText2.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader2, text: lblEntryText2)
                        case 2:
                            lblEntryText3.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader3, text: lblEntryText3)
                        case 3:
                            lblEntryText4.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader4, text: lblEntryText4)
                        case 4:
                            lblEntryText5.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader5, text: lblEntryText5)
                        case 5:
                            lblEntryText6.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader6, text: lblEntryText6)
                        case 6:
                            lblEntryText7.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader7, text: lblEntryText7)
                        case 7:
                            lblEntryText8.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader8, text: lblEntryText8)
                        case 8:
                            lblEntryText9.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader9, text: lblEntryText9)
                        case 9:
                            lblEntryText10.text = elemValue
                            setEntryLabelHeaderTextAndValue(header: lblEntryHeader10, text: lblEntryText10)
                        default:
                            break
                        }
                    }
                }
            }
            break
        case "setAucPrgSq":
            // 일괄 경매 응찰 내역에서 출장우 번호 return
            // 경매 내역(웹뷰) 닫고 화면에 해당 출장우 번호로 응찰 정보 표시
            if let messageBody = message.body as? String,
                !messageBody.isEmpty {
                currentBatchEntryNum = messageBody
                actRequestEntryInfo(entryNum: currentBatchEntryNum)
                self.buttonAction(sender: nil)
            }
            break
        default:
            break
        }
    }
}

extension RealtimeViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .adaptive
        videoCanvas.view = remoteView1
        agoraEngine.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        self.setLocalStorageSpeakerOnOff()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, videoSizeChangedOf sourceType: AgoraVideoSourceType, uid: UInt, size: CGSize, rotation: Int) {
        let videoWidth = size.width
        let videoHeight = size.height
        
        // videoWidth 및 videoHeight를 사용하여 비디오 크기를 처리합니다. -> aspect ratio
        self.remoteView1.frame.size.width = (CGFloat(videoWidth) / CGFloat(videoHeight)) * (self.remoteView1.frame.size.height)
        
        // 동영상 송출 시 가로 넓이만큼 꽉차도록 변경 적용 2021.12.22 jspark
        let viewHeight = self.remoteView1.frame.height
        //2023.02.09 화면전환시 노치가 있는 폰의 경우 뷰의 넒이를 기준으로 하면 영상이 짤리게 나옴. 스크롤기준으로 변경함.
        //let viewWidth = self?.viewRoot.bounds.width
        let viewWidth = self.scrollView.bounds.width
        self.remoteView1.frame.size.width = viewWidth
        self.remoteView1.frame.size.height = viewHeight
        
        self.remoteView1.center.x = (self.scrollView.bounds.width ) / 2
        
        let readyTag = VIEW_TAG.READY_CAST_TAG_BASE + self.currentReadyDelete - 1
        
        if self.view.viewWithTag(readyTag) != nil {
            let readyToView = self.view.viewWithTag(readyTag)
            readyToView!.removeFromSuperview()
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        if self.currentReadyDelete != nil {
            self.addReadyToCast(position:self.currentReadyDelete)
        }
        
        if ((self.remonFirstClose) != nil) {
            if self.remonFirstClose {
                self.remonFirstClose = true
                self.agoraConnect(firstCall:false)
            }
            self.remonFirstClose = false
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if self.currentReadyDelete != nil {
            self.addReadyToCast(position:self.currentReadyDelete)
        }
        
        if self.socketErr ?? false {
            self.socketErr = false
            
            joinChannel()
        }
    }
}
