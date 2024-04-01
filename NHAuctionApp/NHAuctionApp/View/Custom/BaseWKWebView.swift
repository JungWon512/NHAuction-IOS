//
// Created by Sunyoung Choi on 2021/08/27.
//


import UIKit
import WebKit

class BaseWKWebView: WKWebView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.deleteCache()
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always

        super.init(frame: frame, configuration: configuration)
        self.deleteCache()
    }

    convenience init() {
        
        self.init(frame: .zero, configuration: WKWebViewConfiguration())
        self.deleteCache()
        //서버 로그 관리 통일성 위해서 따로 userAgent는 수정 안함
        //self.customUserAgent = WEB.AGENT
    }
}

// MARK:- Public function
extension BaseWKWebView {

     public func deleteCache() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
    }

    public func setAutolayout(withView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    public func openApp(withScheme urlScheme: String, moreString: String?) {
        guard let url = URL.init(string: urlScheme + (moreString ?? "")) else {
            return
        }

        let application = UIApplication.shared
        if application.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                application.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }

    public func callJavaScript(functionName: String) {
//        let js:String = String(format: "ajaxSetting.imgHTML('%@');", imageURL)
        self.evaluateJavaScript(functionName) { (AnyObject, NSError) in
            debug("function \(#function)")
        }
    }

    func loadQueryString(withRequest request: URLRequest, url: URL) {
        let task = URLSession.shared.dataTask(with: request) { (data : Data?, response : URLResponse?, error : Error?) in
            if data != nil
            {
                if let returnString = String(data: data!, encoding: .utf8)
                {
                    debug("loadQueryString : " + returnString)
                    DispatchQueue.main.async {
                        self.loadHTMLString(returnString, baseURL: url)
                    }
                }
            }
        }
        task.resume()
    }
}

// MARK:- Private Function
extension BaseWKWebView {
    fileprivate func setWkWebViewConf() -> WKWebViewConfiguration{
        let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
        webCfg.websiteDataStore = WKWebsiteDataStore.default()
//        webCfg.allowsInlineMediaPlayback = true
        let userController:WKUserContentController = WKUserContentController()

        webCfg.userContentController = userController;
        webCfg.preferences.javaScriptCanOpenWindowsAutomatically = true
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        return webCfg
    }
}

// MARK:- WKScriptMessageHandler
extension BaseWKWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}
