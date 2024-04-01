//
//  Extensions.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/20.
//

import Foundation
import UIKit
import ObjectMapper
import WebKit


extension UIColor {
    
    convenience init(hexString: String) {
        self.init(hexString: hexString, withAlpha: nil)
    }
    convenience init(hexString: String, withAlpha alpha: CGFloat?) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        if alpha != nil {
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: alpha!)
        } else {
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        }
    }
}

// MARK:- UIButton Extension
extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(colorImage, for: forState)
    }
}
extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}


extension String {
    /**
     * 앱 업데이트 유무 판단
     * @param diffVersion {Major}.{Minor}.{Patch}
     * @return true 현재 버전과 diffVersion 을 비교해서 DiffVersion 이 더 큰 경우
     * false 유효한 버전이 아니거나 현재 버전이 더 큰경우.
     */
    func isUpdate(diffVersion: String) -> Bool {
        let currSplit = self.split( separator: ".")
        let diffSplit = diffVersion.split(separator: ".")
        
        // 비교하려는 문자열이 {Major}.{Minor}.{patch} 버전 형태인지
        if (currSplit.count == 3 && diffSplit.count == 3) {
            var curr = Int(currSplit[0])!
            var diff = Int(diffSplit[0])!
            if (curr < diff) {
                return true
            } else if (curr == diff) {
                curr = Int(currSplit[1])!
                diff = Int(diffSplit[1])!
                if (curr < diff) {
                    return true
                } else if (curr == diff) {
                    curr = Int(currSplit[2])!
                    diff = Int(diffSplit[2])!
                    if (curr < diff) {
                        return true
                    }
                }
            }
        }
        return false
    }
    //HTML코드를 표현문자로 변경
    init?(htmlEncodedString: String) {

            guard let data = htmlEncodedString.data(using: .utf8) else {
                return nil
            }

            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
                return nil
            }

            self.init(attributedString.string)

        }
        
}


extension Int {
    /***
     값에 대한 Comma 추가하는 로직
     - Returns:
     */
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}


extension UILabel {
    /***
     문자열이 truncated되는지 판별
     - Returns:
     */
    func willBeTruncated() -> Bool {
        let myText = self.text! as NSString
        
        let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font], context: nil)
        let line = Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
        return line>1 ?true:false
    }
    /***
     문자열 truncated되는 사이즈 계산
     - Returns:
     */
    func truncatedSize() -> CGFloat {
        let myText = self.text! as NSString
        let rect = CGSize(width: 1000, height: self.bounds.height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font], context: nil)
        debugPrint("label width:\(labelSize.width) \(self.frame.size.width)")
        return labelSize.width - self.frame.size.width
    }

}

var vSpinner : UIView?


extension UIScrollView {
    
    func aspectRatio(_ratio:CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: _ratio, constant: 0)
    }
}
extension UIViewController {

    /***
     UI상에서 Spinner를 표시
     - Parameter onView:
     */
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }

    /***
     UI상에서 Spinner 제거
     */
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}


extension WKWebView {
    /***
     웹뷰상의 모든 쿠키를 제거
     */
    func cleanAllCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("All cookies deleted")

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("Cookie ::: \(record) deleted")
            }
        }
    }

    func refreshCookies() {
        self.configuration.processPool = WKProcessPool()
    }
}

extension Collection {
    /** 해당 index가 존재하는지 확인 후 존재할 경우 값을 리턴, 이외에는 nil 리턴 */
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
