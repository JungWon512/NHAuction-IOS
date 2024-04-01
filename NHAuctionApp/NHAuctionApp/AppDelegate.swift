//
//  AppDelegate.swift
//  Test
//
//  Created by Sunyoung Choi on 2021/08/27.
//

import UIKit
import FirebaseCore
import FirebaseDynamicLinks
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //화면 회전을 제어할 변수 선언
    var shouldSupportAllOrientation = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //다이나믹웹링크 초기화
        //LocalStorage.shared.setIsDynamicLinks(isDynamicLinks: "")
        window?.makeKeyAndVisible()
        FirebaseApp.configure()
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        //화면 회전 변수 값에 따라 화면 회전 활성화 지정
        if (shouldSupportAllOrientation == false) {
            return [.portrait]
        } else {
            return [.landscapeRight]
        }

    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        debugPrint("test#1")
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    @available(iOS 9.0, *)
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let urlString = url.absoluteString
        let urlElements = urlString.components(separatedBy: "://")
        
        
//            location.href=nhCowAuction://com.nh.cowauction?taragetUrl=main?place=119&aucYn=Y

        switch urlElements[0] {
            
        case "nhcowauction":
            
            let targetElements = url.absoluteString.components(separatedBy: "targetUrl=")
            if targetElements.count > 1 {
                let redirectUrl = targetElements[1]

                let urlToRedirect = ("\(WEB.HOST)/\(redirectUrl)")

                
                let controller = UIStoryboard.init(name: STORYBOARD.REALTIME, bundle: nil).instantiateViewController(withIdentifier: VIEWCONTROLLER.WEB) as! NHWebViewController
                controller.externUrl = urlToRedirect
                self.window = UIWindow(frame: UIScreen.main.bounds)
                         self.window?.rootViewController = controller
                         self.window?.makeKeyAndVisible()

            }
            
        default:
            break
        }
        
        return true
    }
    // DynamicLink 수신
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Dynamic Link 처리
        // 한글 url로 들어올 경우 null이 떨어짐.
        // null이들어온다면 "https://nhauction.page.link/jmQj72Es5rgktZ6Y9?d=1"이런 식으로 url 끝에 ?d=1 파라미터를 붙여 디버깅 해볼것
        if let incomingURL = userActivity.webpageURL {
            debugPrint("incomingURL : \(incomingURL)")
            _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLinks, error in
                
                guard let realLinks = dynamicLinks?.url?.absoluteString, error == nil else {
                    debugPrint("### DynamicLinks error")
                    return
                }
                //LocalStorage.shared.setIsDynamicLinks(isDynamicLinks: realLinks)
                Singleton.shared.isNotRunningDynamicLink = realLinks;
            }
        } else {
            //..
        }
        //background -> foreground 로 갈경우 
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { dynamiclink, error in
            guard let realLinks = dynamiclink?.url?.absoluteString
             else {return}
            debugPrint("### AppDelegate DynamicLink is app background -> foreground: \(realLinks)")
            guard let win = self.window, let rvc = win.rootViewController, rvc.isKind(of: BaseNavigationViewController.self) else {
                return
            }
            
            guard let baseNavigationViewController = rvc as? BaseNavigationViewController else {
                return
            }
            
            let viewControllers = baseNavigationViewController.viewControllers
            for view in viewControllers {
                if (view.isKind(of: NHWebViewController.self)) {
                    let nhWebViewController = view as? NHWebViewController
                    nhWebViewController?.dynamicLinks = realLinks
                } else if (view.isKind(of: RealtimeViewController.self)) {
                    let realTimeViewController = view as? RealtimeViewController
                    realTimeViewController?.checkDynamicLinks(link: realLinks)
                } else {
                    
                }
            }
        }
        return handled
    }
}


