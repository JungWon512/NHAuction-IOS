//
// Created by Sunyoung Choi on 2021/08/27.
//
import UIKit
import Toast_Swift

typealias VoidClosure = (() -> Swift.Void)?

/// View Event
protocol ViewEventDelegate {
    func event(viewType: String, data: Any)
}

/// 베이스 뷰
class BaseViewController: UIViewController {
    
    //////////////////////////////////////
    // Local Values
    static var main: UIViewController! {
        get {
            return topViewController()
        }
    }

    static var root: UIViewController? {
        get {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    var isHiddenBarLine: Bool = false
    var eventDelegate: ViewEventDelegate? // View Event
    //////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open func setData(data: Any) {}
}

// MARK:- private Functions
extension BaseViewController {

}

// MARK:- Public Functions
extension BaseViewController {
    
   
    
    func push(_ viewController: UIViewController, animated: Bool) {
//        viewController.setNavigationBackButton(title: "")
        
        if let naviVC = BaseViewController.main?.navigationController {
            naviVC.pushViewController(viewController, animated: animated)
        } else if self.navigationController != nil {
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem()
            self.navigationItem.backBarButtonItem?.title = ""
            self.navigationController!.pushViewController(viewController, animated: animated)
            
        } else {
            
            debug("[Error] navigationController is nil ")
        }
    }
    
    func pop(animated: Bool) {
        if let naviVC = BaseViewController.main?.navigationController {
            naviVC.popViewController(animated: animated)
        } else if self.navigationController != nil {
            self.navigationController!.popViewController(animated: animated)
        } else {
            debug("[Error] navigationController is nil ")
        }
    }
    
    
    
    func showPopup(vc: UIViewController, animated: Bool = false) {
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: animated, completion: nil)
    }
    
    func hidePopup(animated: Bool = false) {
        self.dismiss(animated: animated, completion: nil)
    }
    
    
    func shareImage(_ image : [UIImage]){
        let activityViewController = UIActivityViewController(activityItems: image, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    func showToast(text: String) {
            // Style
            var style = ToastStyle()
            style.messageAlignment = .center
            style.messageFont = .systemFont(ofSize: 14.0)
            // Toast
            self.view.makeToast(text, style: style)
    }
    
    func showToastReceive(text: String) {
            // Style
            var style = ToastStyle()
            style.messageAlignment = .right
            style.messageFont = .systemFont(ofSize: 14.0)
            // Toast
            self.view.makeToast(text, style: style)
    }
    
    /***
     단순 테스트 Toast 함수
     - Parameter text: 화면에 표시할 텍스트
     */
    func showToastNH(text: String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width*0.1 , y: 385, width: self.view.frame.size.width * 0.8, height: 80))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font =  UIFont(name: "NotoSansCJKkr-Bold", size: 25)!
        toastLabel.textAlignment = .center;
        toastLabel.text = text
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
            
        }, completion: {
            (isCompleted) in toastLabel.removeFromSuperview()
            
        })
 
    }

    /***
     화면 중간에 표시하는 꽉찬 큰 Toast
     - Parameters:
       - text: 화면에 표시할 텍스트
       - yPos: y위치
     */
    func showToastNHBig(text: String, yPos: Int) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width * 0 , y: CGFloat(yPos), width: self.view.frame.size.width * 1, height: 120))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font =  UIFont(name: "NotoSansCJKkr-Bold", size: 40)!
        toastLabel.textAlignment = .center;
        toastLabel.text = text
        toastLabel.alpha = 1.0
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
            
        }, completion: {
            (isCompleted) in toastLabel.removeFromSuperview()
            
        })
 
    }

    /***
     화면 중간에 표시하는 꽉찬 큰 Toast( 초록색 )
     - Parameters:
       - string: 화면에 표시할 텍스트
       - greenStart: 초록색이 시작될 위치
       - greenLength: 초록색의 길이
       - yPos: y위치
     */
    func showToastNHBigColorGreen(string:String, greenStart:Int, greenLength:Int, yPos: Int) {
        
        
        let attributedString = NSMutableAttributedString(string: string, attributes: [
            .font: UIFont(name: "NotoSansCJKKR-Bold", size: 40)!,
            .foregroundColor: UIColor(white: 255.0 / 255.0, alpha: 1.0),
          .kern: -1.92
        ])

        attributedString.addAttributes([
          .font: UIFont(name: "NotoSansCJKKR-Bold", size: 40)!,
          .foregroundColor: UIColor(red: 134.0/255.0, green: 229.0 / 255.0, blue: 127.0/255.0, alpha: 1.0)
        ], range: NSRange(location: greenStart, length: greenLength))
        
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width * 0 , y: CGFloat(yPos), width: self.view.frame.size.width * 1, height: 120))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font =  UIFont(name: "NotoSansCJKkr-Bold", size: 40)!
        toastLabel.textAlignment = .center;
        toastLabel.attributedText = attributedString
        toastLabel.alpha = 1.0
        toastLabel.clipsToBounds = true
        toastLabel.tag = LABEL_TAG.GREEN_LABEL
        self.view.addSubview(toastLabel)

    }
    /***
     화면 중간에 표시하는 꽉찬 큰 Toast( 빨강색 )
     - Parameters:
       - string: 화면에 표시할 텍스트
       - greenStart: 빨강색이 시작될 위치
       - greenLength: 빨강색의 길이
       - yPos: y위치
     */
    func showToastNHBigColorRed(string:String, redStart:Int, redLength:Int, yPos: Int) {
        
        
        let attributedString = NSMutableAttributedString(string: string, attributes: [
            .font: UIFont(name: "NotoSansCJKKR-Bold", size: 40)!,
            .foregroundColor: UIColor(white: 255.0 / 255.0, alpha: 1.0),
            .kern: -1.92
        ])
        
        attributedString.addAttributes([
            .font: UIFont(name: "NotoSansCJKKR-Bold", size: 40)!,
            .foregroundColor: UIColor(red: 242.0 / 255.0, green: 40.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
        ], range: NSRange(location: redStart, length: redLength))
        
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width * 0 , y: CGFloat(yPos), width: self.view.frame.size.width * 1, height: 120))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font =  UIFont(name: "NotoSansCJKkr-Bold", size: 40)!
        toastLabel.textAlignment = .center;
        toastLabel.attributedText = attributedString
        toastLabel.alpha = 1.0
        toastLabel.clipsToBounds = true
        toastLabel.tag = LABEL_TAG.RED_LABEL
        self.view.addSubview(toastLabel)
    }

    /***
     화면 중간에 표시하는  Toast ( 현재 사용 안함 )
     - Parameters:
       - string: 화면에 표시할 텍스트
     */
    func showToastNHWeb(text: String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width*0.1 , y: 350, width: self.view.frame.size.width * 0.8, height: 100))
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.numberOfLines = 0
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font =  UIFont(name: "NotoSansCJKkr-Bold", size: 20)!
        toastLabel.textAlignment = .center;
        toastLabel.text = text
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
            
        }, completion: {
            (isCompleted) in toastLabel.removeFromSuperview()
            
        })

       
        
    }
    
    /***
     socket 전송시 문자표시하기 위함 method
     - Parameter text: 화면에 표시할 텍스트
     */
    func showToastSend(text: String) {
            // Style
            var style = ToastStyle()
            style.messageAlignment = .left
            style.messageFont = .systemFont(ofSize: 14.0)
            style.verticalPadding = 100
            self.view.makeToast(text, duration: 1.5,
                               point: CGPoint(x: 187, y: 200),
                               title: "타이틀",
                               image: UIImage(named: ""),
                               style: .init(),
                               completion: nil)
            // Toast
//            self.view.makeToast(text, style: style)
    }
    
    
    
    
        
    func popupOneBtn(withTitle titleStr: String, msg: String, buttonTitle: String? = TEXT.CONFIRM, buttonAction: VoidClosure = nil) {
            let popupStoryBoard = UIStoryboard.init(name: STORYBOARD.POPUP, bundle: nil)
            let vc = popupStoryBoard.instantiateViewController(withIdentifier: VIEWCONTROLLER.POPUP_ONE_BTN) as! PopupOneBntViewController
            vc.popupTitle = titleStr
            vc.popupMsg = msg
            vc.popupMsgAttr =  nil
            vc.cancelHandler = buttonAction
            vc.cancelTitle = buttonTitle
            showPopup(vc: vc)
    }
    
    func popupOneBtn(withTitle titleStr: String, msgAttr: NSMutableAttributedString, buttonTitle: String? = TEXT.CONFIRM, buttonAction: VoidClosure = nil) {
            let popupStoryBoard = UIStoryboard.init(name: STORYBOARD.POPUP, bundle: nil)
            let vc = popupStoryBoard.instantiateViewController(withIdentifier: VIEWCONTROLLER.POPUP_ONE_BTN) as! PopupOneBntViewController
            vc.popupTitle = titleStr
            vc.popupMsgAttr = msgAttr
            vc.cancelHandler = buttonAction
            vc.cancelTitle = buttonTitle
            showPopup(vc: vc)
    }
        
    func popupTwoBtn(msg: String,
                     leftTitle: String? = TEXT.CANCEL, rightTitle: String? = TEXT.CONFIRM,
                     leftBtnAction: VoidClosure = nil,
                     rightBtnAction: VoidClosure = nil) {
        let popupStoryBoard = UIStoryboard.init(name: STORYBOARD.POPUP, bundle: nil)
        let vc = popupStoryBoard.instantiateViewController(withIdentifier: VIEWCONTROLLER.POPUP_TWO_BTN) as! PopupTwoBntViewController
        vc.popupMsg = msg
        vc.cancelTitle = leftTitle!
        vc.confirmTitle = rightTitle!
        vc.leftcompletion = leftBtnAction
        vc.completion = rightBtnAction
        showPopup(vc: vc)
    }
}

// MARK:- Private Functions
extension BaseViewController {
    
    private static func topViewController(from viewController: UIViewController? = BaseViewController.root) -> UIViewController? {
        if let tabBarViewController = viewController as? UITabBarController {
            return topViewController(from: tabBarViewController.selectedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        } else {
            return viewController
        }
    }
    
}

// MARK:- Private Functions
//extension BaseViewController: UIGestureRecognizerDelegate{
//    
//    @objc func scrollViewTapped(recognizer: UIGestureRecognizer) {
//        let allScrollViews: [UIScrollView] = self.view.getAllSubviews(view: self.view)
//        
//        for view in allScrollViews{
//            view.endEditing(true)
//        }
//    }
//}
//
//
extension UIView {
    func getAllSubviews<T: UIView>(view: UIView) -> [T] {
        var subviewArray = [T]()
        if view.subviews.count == 0 {
            return subviewArray
        }
        for subview in view.subviews {
            subviewArray += self.getAllSubviews(view: subview) as [T]
            if let subview = subview as? T {
                subviewArray.append(subview)
            }
        }
        return subviewArray
    }
}
