//
//  Extensions.swift
//  RandomWheel
//
//  Created by Anton Voloshuk on 25.02.2021.
//

import Foundation
import UIKit

extension UIColor{
    func almostEqual(compare: UIColor)->Bool{
        
        if(self.cgColor.colorSpace != compare.cgColor.colorSpace){
            return false
        }
        let componentsSelf=self.cgColor.components
        let componentsCompare=compare.cgColor.components
        
        if(componentsSelf == nil || componentsCompare == nil){
            return false
        }
        if(componentsSelf?.count != componentsCompare?.count){
            return false
        }

        var diff:CGFloat=0
        for i in 0..<componentsSelf!.count{
            let maxValue = max(componentsSelf![i],componentsCompare![i])
            let minValue = min(componentsSelf![i],componentsCompare![i])
            diff+=abs(maxValue-minValue)
        }
        if(diff<0.5){
            return true
        }
        return false
    }
}
