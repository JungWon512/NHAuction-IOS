//
//  ViewController.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/08/27.
//

import UIKit

/***
 버튼 2개용 ViewController
 */
class PopupTwoBntViewController: PopupBaseViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var cancelButton: BaseButton!
    @IBOutlet weak var confirmButton: BaseButton!
    
    @IBOutlet weak var titleLblHeight: NSLayoutConstraint!
    @IBOutlet weak var underLineViewHeight: NSLayoutConstraint!
    @IBOutlet weak var popupViewHeight: NSLayoutConstraint!
    
    var leftcompletion: VoidClosure = nil
    var completion: VoidClosure = nil
    
    var popupTitle : String?
    var popupMsg: String?
    
    var cancelTitle: String = ""
    var confirmTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hexString: COLOR.ARGB_80000000)
        self.popupView.clipsToBounds = true
//        self.popupView.layer.borderWidth = 2.0
        self.popupView.layer.cornerRadius = 20.0
        
//        let borderColor : UIColor = UIColor( red: 118/255, green: 186/255, blue:1, alpha: 1.0 )
//        self.popupView.layer.borderColor = borderColor.cgColor

        self.confirmButton.cornerRadius = 0.0
        self.confirmButton.colorStyle = .nhauction
        
        self.cancelButton.cornerRadius = 0.0
        self.cancelButton.colorStyle = .nhcancel
        
        self.confirmButton.titleLabel?.font =  UIFont(name: FONT.APP_BOLD, size: 24)
        self.cancelButton.titleLabel?.font =  UIFont(name: FONT.APP_BOLD, size: 24)
        
        self.msgLbl.text = self.popupMsg
        self.msgLbl.font = UIFont(name: FONT.APP_MEDIUM, size: 20)
        self.msgLbl.textColor = UIColor( red: 0/255, green: 0/255, blue:0, alpha: 1.0 )

        
        self.cancelButton.setTitle(self.cancelTitle, for: .normal)
        self.cancelButton.setTitle(self.cancelTitle, for: .highlighted)
        
        self.confirmButton.setTitle(self.confirmTitle, for: .normal)
        self.confirmButton.setTitle(self.confirmTitle, for: .highlighted)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func confirmButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: self.completion)
    }
    
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: false, completion: self.leftcompletion)
    }

}
