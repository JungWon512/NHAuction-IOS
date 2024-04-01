//
//  SceneDelegate.swift
//  Test
//
//  Created by Sunyoung Choi on 2021/08/27.
//

import UIKit
import FirebaseDynamicLinks

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        debugPrint("### willConnectTo")
        //다이나믹웹링크 초기화
        //LocalStorage.shared.setIsDynamicLinks(isDynamicLinks: "")
        guard let _ = (scene as? UIWindowScene) else {
            return
        }
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
    }

    /***
     Scheme에 따라 동작하게 설정
     - Parameters:
       - scene:
       - URLContexts:
     */
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        for context in URLContexts {

            let urlHost = context.url.host!
            let url = context.url
            let urlString = context.url.absoluteURL.absoluteString
            let urlElements = urlString.components(separatedBy: "://")

            switch urlElements[0] {
                
            case "nhcowauction":
                switch urlHost
                {
                case "com.nh.cowauction":
                    let targetElements = url.absoluteString.components(separatedBy: "targetUrl=")
                    if targetElements.count > 1 {
                        let redirectUrl = targetElements[1]

                        let urlToRedirect = ("\(WEB.HOST)/\(redirectUrl)")
                        let controller = UIStoryboard.init(name: STORYBOARD.REALTIME, bundle: nil).instantiateViewController(withIdentifier: VIEWCONTROLLER.WEB) as! NHWebViewController
                        controller.externUrl = urlToRedirect
                        if let windowScene = scene as? UIWindowScene {
                            let window = UIWindow(windowScene: windowScene)
                            window.rootViewController = controller
                            self.window = window
                            window.makeKeyAndVisible()
                            
                        }

                    }
                    break
                default:
                    break
                }
                
            default:
                break
            }



        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Dynamic Link 처리
        // 한글 url로 들어올 경우 null이 떨어짐.
        // null이들어온다면 "https://nhauction.page.link/jmQj72Es5rgktZ6Y9?d=1"이런 식으로 url 끝에 ?d=1 파라미터를 붙여 디버깅 해볼것
        if let incomingURL = userActivity.webpageURL {
            debugPrint("incomingURL : \(incomingURL)")
            _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLinks, error in
                debugPrint("dynamicLinks : \(String(describing: dynamicLinks))")

                guard let realLinks = dynamicLinks?.url?.absoluteString, error == nil else {
                    debugPrint("### DynamicLinks error")
                    return
                }
                debugPrint("### userActivity realLinks \(realLinks)")
                
                debugPrint("### DynamicLinks error == nil")
                //앱 초기실행시에는 userdefaults를 사용함.
                //LocalStorage.shared.setIsDynamicLinks(isDynamicLinks: realLinks);
                Singleton.shared.isNotRunningDynamicLink = realLinks;
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
        }
    }
        
    func sceneDidDisconnect(_ scene: UIScene) {
            
            // Called as the scene is being released by the system.
            // This occurs shortly after the scene enters the background, or when its session is discarded.
            // Release any resources associated with this scene that can be re-created the next time the scene connects.
            // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
        
    func sceneDidBecomeActive(_ scene: UIScene) {
        debugPrint("### sceneDidBecomeActive");
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
        
    func sceneWillResignActive(_ scene: UIScene) {
        debugPrint("### sceneDidBecomeActive");
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
        
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        debugPrint("sceneWillEnterForeground")
    }
        
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        debugPrint("enterBackground")
        LocalStorage.shared.setIsBackground(isBackground: true)
    }
}
    
