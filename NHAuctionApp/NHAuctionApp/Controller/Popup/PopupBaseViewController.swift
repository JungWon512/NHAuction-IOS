//
//  ViewController.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/08/27.
//

import UIKit

/***
 팝업의 BaseViewController
 */
class PopupBaseViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.view.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        removeAnimate(animated: flag, completion: completion)
    }
}

// MAKR:- Private function
extension PopupBaseViewController {
    
    func showAnimate() {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        })
    }
    
    func removeAnimate(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished) {
                // 애니메이션 True시 애니메이션이 중복으로 나타나서 부자연스러움.
                super.dismiss(animated: false, completion: completion)
            }
        })
    }
}
