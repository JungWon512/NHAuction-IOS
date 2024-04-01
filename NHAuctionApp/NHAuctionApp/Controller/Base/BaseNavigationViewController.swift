//
//  BaseNavigationViewController.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/06.
//


import UIKit

/***
 Customized NavigationViewController
 */
class BaseNavigationViewController: UINavigationController {
    
    let underLineView = UIView()
    var isHiddenBarLine : Bool = false {
        didSet {
            self.underLineView.isHidden = self.isHiddenBarLine
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar Style을 검은색으로 바꿈으로써 Status Bar 스타일을 흰색으로 바꿀수 있다.
        self.navigationBar.barStyle = .black
        
        // 불투명 처리를 하지 않음.
        self.navigationBar.isTranslucent = false
        
        // BackgroundColor를 바꿔도 바뀌지 않음.. -> _UIBarBackground라는 녀석이 self.navigationBar.background 앞을 가리고 있음
        self.navigationBar.backgroundColor = .clear // UIColor.init(hexString: COLOR.BASE_COLOR_1D2029)
        
        // 실제 Bar Background color 설정 :  _UIBarBackground의 view 색상을 아래코드로 변경할 수 있음.
//        self.navigationBar.barTintColor = UIColor.init(hexString: COLOR.BASE_COLOR_1D2029)
        
        // 기본적으로 제공해주는 navigationBar의 언더라인(이라 쓰고 그림자shadow라고 읽는다ㅋ)를 삭제
        self.navigationBar.shadowImage = UIImage() // UIColor.init(hexString: COLOR.ARGB_33FFFFFF).as1PtImage()

        
        self.underLineView.frame = CGRect.init(x: 0.0,
                                          y: self.navigationBar.frame.height - 1,
                                          width: self.navigationBar.frame.width,
                                          height: 1.0)
//        underLineView.backgroundColor = UIColor.init(hexString: COLOR.ARGB_1AE5E5E5)
        
        // insertSubView로 라인을 추가하며, view의 index(쌓여진 순서)의 최상단으로 올린다. 최하단은 이녀석 _UIBarBackground
        self.navigationBar.insertSubview(underLineView, at: (self.navigationBar.subviews.count - 1))
        
        // 백버튼 글씨, BarButton title등의 글씨색을 흰색으로 변경
        self.navigationBar.tintColor = .white
        
        
        // navigationBar 폰트 + 크기 변경
//        guard let font = UIFont.init(name: FONT.APPLE_GOTHIC_MEDIUM, size: FONTSIZE.PT_16) else {
//            return
//        }
////        let fontAttribute = [ NSAttributedStringKey.font :  font]
//        self.navigationBar.titleTextAttributes = fontAttribute
//        // BarButton들의 폰트도 한꺼번에 바꿔준다.
//        UIBarButtonItem.appearance().setTitleTextAttributes(fontAttribute, for: .normal)
        

        
//        self.push(_ : controller, animated: false)
    }
}
