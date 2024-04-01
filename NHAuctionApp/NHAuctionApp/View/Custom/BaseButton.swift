//
//  ViewController.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/08/27.
//

import UIKit

enum ColorStyle: Int {
    case point, gray, grayborder, nhauction, nhcancel
}

//@IBDesignable
class BaseButton: UIButton {
        
    public var colorStyle: ColorStyle = .gray {
        didSet {
            setButtonColor()
        }
    }
    
    public var cornerRadius: CGFloat = 2.5 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    override var buttonType: UIButton.ButtonType {
        get {
            return .custom
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUIButton()
        setButtonColor()
    }
}

// MARK:- Public Functions
extension BaseButton {
    
    public func setButtonColor() {
        if self.colorStyle == .point {
            setBackgroundColor(color: UIColor.init(hexString: COLOR.RGB_FD6705), forState: .normal)
            setBackgroundColor(color: UIColor.init(hexString: COLOR.RGB_994F20), forState: .highlighted)
        } else if self.colorStyle == .nhauction {
            setBackgroundColor(color: UIColor.init(hexString: COLOR.RGB_007EFF), forState: .normal)
            setBackgroundColor(color: UIColor.init(hexString: COLOR.RGB_007EFF), forState: .highlighted)
        } else if self.colorStyle == .nhcancel {
            setBackgroundColor(color: UIColor.init(hexString: COLOR.RGB_CCCCCC), forState: .normal)
            setBackgroundColor(color: UIColor.init(hexString: COLOR.RGB_CCCCCC), forState: .highlighted)
        } else if self.colorStyle == .grayborder{
            setBackgroundColor(color: .clear, forState: .normal)
            setBackgroundColor(color: .clear, forState: .highlighted)
            self.layer.borderColor = UIColor.init(hexString: COLOR.RGB_676A71).cgColor
            setTitleCustomColor(color: UIColor.init(hexString: COLOR.RGB_676A71))
        } else {
//            setBackgroundColor(color: UIColor.init(hexString: COLOR.RGB_676A71), forState: .normal)
//            setBackgroundColor(color: UIColor.init(hexString: COLOR.RGB_43464B), forState: .highlighted)
        }
    }
}

// MARK:- Private Functions
extension BaseButton {
    
    private func setUIButton() {
        self.backgroundColor = .clear
        
        self.titleLabel?.font = UIFont.init(name: FONT.APP_MEDIUM, size: FONTSIZE.PT_16)
        setTitleCustomColor(color: nil)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1.0
    }
    
    private func setTitleCustomColor(color: UIColor?) {
        if color == nil {
            self.setTitleColor(.white, for: .normal)
            self.setTitleColor(.white, for: .highlighted)
            self.setTitleColor(.white, for: .selected)
        } else {
            self.setTitleColor(color, for: .normal)
            self.setTitleColor(color, for: .highlighted)
            self.setTitleColor(color, for: .selected)
        }
    }
}
