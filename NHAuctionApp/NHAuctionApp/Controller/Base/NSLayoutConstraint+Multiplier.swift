//
//  NSConstraint.swift
//  SimpleRemon
//
//  Created by Chance Kim on 26/06/2019.
//

import UIKit

/***
 동영상 해상도 변경시 contraint바꿔주는 extension
 */
extension NSLayoutConstraint {
    func setMultiplier( multiplier:CGFloat)  {
        NSLayoutConstraint.deactivate([self])
        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
    }
}
