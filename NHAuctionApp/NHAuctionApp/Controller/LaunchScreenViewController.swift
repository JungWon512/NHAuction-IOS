//
//  LaunchScreenViewController.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/10/01.
//

import Foundation
import UIKit

/***
 로딩이미지 화면표시할시 동작하는 ViewController
 */
class LaunchScreenViewController:BaseViewController {
    
    @IBOutlet weak var permissionView: UIView!
    @IBOutlet weak var permissionInnerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        permissionView.layer.cornerRadius = 15
        permissionInnerView.layer.cornerRadius = 15
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let connected = connectedToNetwork()
            if connected != true {
                self.popupOneBtn(withTitle: TEXT.NOTICE, msg: "네트워크에 연결되지 않았습니다.", buttonAction: {
                    self.pop(animated: true)
                    exit(1)
                })
            } else {
                let agreeYN = LocalStorage.shared.getIsAgreePermission()
                if agreeYN {
                    self.appVersion()
                } else {
                    self.permissionView.isHidden = false
                    debugPrint("VIEW")
                }
            }
        }
    }
    
    /***
     권한 사용승인
     - Parameter sender:
     */
    @IBAction func agreePermission(_ sender: Any) {
        LocalStorage.shared.setIsAgreePermission(isAgreePermission: true)
        self.appVersion()
    }
    
    /***
     기본 Webview로 이동
     */
    func goWebView(){
        debugPrint("WEB VIEW로 이동")
        
        let controller = UIStoryboard.init(name: STORYBOARD.REALTIME, bundle: nil).instantiateViewController(withIdentifier: VIEWCONTROLLER.WEB) as! NHWebViewController
        controller.modalPresentationStyle = .overFullScreen
        self.push(_ : controller, animated: false)
    }
    
    /***
     appVersion체크하는 로직
     */
    func appVersion(){
        callAppVersion() {
            result in
            if result.isSuccess {
                let appversion = result.value!
                // 응답 받으면 agoraConnect 값을 호출
                switch appversion.success {
                case true:
                    let maxVersion = appversion.info!.MAX_VERSION
                    let minVersion = appversion.info!.MIN_VERSION
                    let netHost = appversion.info!.NET_HOST
                    let netPort = appversion.info!.NET_PORT
                    
                    LocalStorage.shared.setNetHost(netHost: netHost)
                    LocalStorage.shared.setNetPort(netPort: netPort)
                    
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                    
                    let isUpgradeMin = currentVersion.isUpdate(diffVersion: minVersion)
                    //                    isUpgradeMin = true
                    if isUpgradeMin == true {
                        self.popupOneBtn(withTitle: TEXT.NOTICE, msg: "최신 업데이트가 있습니다.\n업데이트 하시겠습니까?", buttonTitle: "앱 업데이트", buttonAction: {
                            goAppStore()
                        })
                        
                    } else {
                        let isUpgradeMax = currentVersion.isUpdate(diffVersion: maxVersion)
                        //                        isUpgradeMax = true
                        if isUpgradeMax == true {
                            self.popupTwoBtn(msg: "최신 업데이트가 있습니다.\n업데이트 하시겠습니까?" , leftTitle: "나중에 ",rightTitle: "앱 업데이트", leftBtnAction: {
                                self.goWebView()
                            }, rightBtnAction: {
                                goAppStore()
                            })
                            
                        } else {
                            
                            self.goWebView()
                        }
                    }
                    break
                case false:
                    self.goWebView()
                    break
                }
            } else {
                self.popupOneBtn(withTitle: TEXT.NOTICE, msg: "서버에 접속 할수 없습니다. \n 잠시후 다시 시도 하세요. ", buttonAction: {
                    exit(0)
                })
            }
        }
    }
}
