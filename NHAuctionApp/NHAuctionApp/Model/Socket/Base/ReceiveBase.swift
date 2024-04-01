//
//  Base.swift
//  NHAuctionApp
//
//  Created by Sunyoung Choi on 2021/09/26.
//

import Foundation

/***
 수신된 패킷을 파싱하고 저장할 Model
 */
class ReceiveBase: NSObject {


    init?(transaction: String) {
        super.init()

        let initArray = transaction.components(separatedBy: "|")
        var json = "{"
        var elements: [String] = []
        var pos = 0

        for property in Mirror(reflecting: self).children {
            if initArray.indices.contains(pos) {
                let selectedType = type(of: property.value)
                if selectedType is String.Type {
                    // KPN일때는 KPN을 지우고 값을 추가
                    if property.label == "entryKpn" {

                        let trimValue = initArray[pos].replacingOccurrences(of: "KPN", with: "")
                        if trimValue == "" {
                            elements.append("\"\(property.label!)\":\"-\"")
                        } else {
                            elements.append("\"\(property.label!)\":\"" + trimValue + "\"")
                        }
                        //문자열에 null이 들어올때는 - 로
                    } else if initArray[pos] == "null" {
                        elements.append("\"\(property.label!)\":\"-\"")
                    } else if initArray[pos] == "" {
                        elements.append("\"\(property.label!)\":\"-\"")
                    } else {
                        elements.append("\"\(property.label!)\":\"" + initArray[pos] + "\"")
                    }
                }
                if selectedType is Int.Type {
                    elements.append("\"\(property.label!)\":" + initArray[pos])
                }
            }
            pos = pos + 1
        }
        json = json + elements.joined(separator: ",")
        json = json + "}"

        if let jsonData = json.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]
                // Loop
                for (key, value) in json {
                    let keyName = key as String
                    let keyValue: AnyObject = value
                    self.setValue(keyValue, forKey: keyName)
                }
            } catch let error as NSError {
                debugPrint("Failed to load: \(error.localizedDescription)")
            }
        } else {
            debugPrint("json is of wrong format!")
        }
    }

    override init() {
        super.init()
    }
    
}
