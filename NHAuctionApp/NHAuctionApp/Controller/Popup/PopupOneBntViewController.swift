//
//  ViewController.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/08/27.
//

import UIKit


/***
 단일 버튼용 ViewController
 */
class PopupOneBntViewController: PopupBaseViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var cancelButton: BaseButton!
    
    @IBOutlet weak var titleLblHeight: NSLayoutConstraint!
    @IBOutlet weak var underLineViewHeight: NSLayoutConstraint!
    @IBOutlet weak var popupViewHeight: NSLayoutConstraint!
    
    var popupTitle : String?
    var popupMsg: String?
    var popupMsgAttr: NSMutableAttributedString?
    var cancelTitle: String?
    var cancelHandler: VoidClosure = nil
    
    
//    let attributedString = NSMutableAttributedString(string: string, attributes: [
//      .font: UIFont(name: "NotoSansCJKKR-Medium", size: 27.0)!,
//      .foregroundColor: UIColor(white: 26.0 / 255.0, alpha: 1.0),
//      .kern: -1.92
//    ])
////        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 2, length: 1))
//    attributedString.addAttributes([
//      .font: UIFont(name: "NotoSansCJKKR-Bold", size: 27.0)!,
//      .foregroundColor: UIColor(red: 0.0, green: 126.0 / 255.0, blue: 1.0, alpha: 1.0)
//    ], range: NSRange(location: blueStart, length: blueLength))
//
//    self.attrString  = attributedString
//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hexString: COLOR.ARGB_80000000)
        self.popupView.clipsToBounds = true
//        self.popupView.layer.borderWidth = 2.0
        self.popupView.layer.cornerRadius = 20.0
//        let borderColor : UIColor = UIColor( red: 118/255, green: 186/255, blue:1, alpha: 1.0 )
        
        
//        self.popupView.layer.borderColor = borderColor.cgColor

        self.cancelButton.cornerRadius = 0.0
        self.cancelButton.colorStyle = .nhauction
        self.cancelButton.titleLabel?.font =  UIFont(name: FONT.APP_BOLD, size: 24)
        
        if self.popupMsg == nil {
            debugPrint("A")
            self.msgLbl.attributedText = self.popupMsgAttr
        } else {
            debugPrint("B")
            self.msgLbl.text = self.popupMsg
            self.msgLbl.font = UIFont(name: FONT.APP_MEDIUM, size: 20)
            self.msgLbl.textColor = UIColor( red: 0/255, green: 0/255, blue:0, alpha: 1.0 )
        }
        self.cancelButton.setTitle(self.cancelTitle, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: self.cancelHandler)
    }

}
