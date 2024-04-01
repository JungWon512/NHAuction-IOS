//
//  StatusView.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/25.
//

import Foundation
import UIKit

/***
 STATUS_VIEW의 AttributedSting 만드는 Class
 */
struct STATUS_VIEW {
    let attrString: NSMutableAttributedString

    /***
     파랑색 문장열을 포함할때 사용
     - Parameters:
       - string: 화면에 표시할 텍스트
       - blueStart: 파랑색의 시작 위치
       - blueLength: 파랑색의 길이
     */
    init?(string: String, blueStart: Int, blueLength: Int) {
        let attributedString = NSMutableAttributedString(string: string, attributes: [
            .font: UIFont(name: "NotoSansCJKKR-Medium", size: 27.0)!,
            .foregroundColor: UIColor(white: 26.0 / 255.0, alpha: 1.0),
            .kern: -1.92
        ])
        attributedString.addAttributes([
            .font: UIFont(name: "NotoSansCJKKR-Bold", size: 27.0)!,
            .foregroundColor: UIColor(red: 0.0, green: 126.0 / 255.0, blue: 1.0, alpha: 1.0)
        ], range: NSRange(location: blueStart, length: blueLength))

        self.attrString = attributedString


    }

    /***
     빨강색 문장열을 포함할때 사용
     - Parameters:
       - string: 화면에 표시할 텍스트
       - redStart: 빨강색의 시작 위치
       - redLength: 빨강색의 길이
     */
    init?(string: String, redStart: Int, redLength: Int) {
        let attributedString = NSMutableAttributedString(string: string, attributes: [
            .font: UIFont(name: "NotoSansCJKKR-Medium", size: 27.0)!,
            .foregroundColor: UIColor(white: 26.0 / 255.0, alpha: 1.0),
            .kern: -1.92
        ])
//        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 2, length: 1))
        attributedString.addAttributes([
            .font: UIFont(name: "NotoSansCJKKR-Bold", size: 27.0)!,
            .foregroundColor: UIColor(red: 242.0 / 255.0, green: 40.0 / 255.0, blue: 0.0, alpha: 1.0)
        ], range: NSRange(location: redStart, length: redLength))

        self.attrString = attributedString
    }


    func attr() -> NSMutableAttributedString {
        return self.attrString
    }

}
