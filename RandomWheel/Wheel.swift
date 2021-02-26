//
//  Wheel.swift
//  WheelOfChoice
//
//  Created by Anton Voloshuk on 16.02.2021.
//

import Foundation
import UIKit



protocol WheelDelegate:class {
    func modelUpdate()
}



class Wheel{
    struct wheelElement{
        var description: String
        var color: UIColor
    }
    
    var delegate: WheelDelegate?
    private var data: [wheelElement] = []{
        didSet{
            var arr=[String]()
            for i in 0..<self.data.count{
                arr.append(self.data[i].description)
            }
            UserDefaults.standard.setValue(arr, forKey: "data")
        }
    }
    
    init( ) {
        guard let tmp = (UserDefaults.standard.object(forKey: "data") as! [String]?)
        else{
            self.addNew(NSLocalizedString("IDS_SECTOR_YES", tableName: "Strings", bundle: .main, value: "", comment: ""))
            self.addNew(NSLocalizedString("IDS_SECTOR_NO", tableName: "Strings", bundle: .main, value: "", comment: ""))
            return
        }
        for i in 0..<tmp.count{
            self.addNew(tmp[i])
        }
    }
    
    func addNew(_ newElement: String){
        var color: UIColor
        
        if #available(iOS 13.0, *) {
             color = UIColor(cgColor:CGColor.init(genericCMYKCyan: CGFloat.random(in: 0..<1), magenta: 0.4, yellow: CGFloat.random(in: 0..<1), black: 0, alpha: 1 ))
        } else {
             color = UIColor.init(hue: CGFloat.random(in: 0..<1), saturation: CGFloat.random(in: 0..<1), brightness: CGFloat.random(in: 0..<1), alpha: 1)
        }
        
        while(self.data.contains(where: { element in
            if(element.color==color){
                return true
            }
            else{
                return false
            }
        }) || (self.data.last?.color ?? UIColor(red: 0, green: 0, blue: 0, alpha: 0)).almostEqual(compare: color)){
            print("reinit color")
            if #available(iOS 13.0, *) {
                 color = UIColor(cgColor:CGColor.init(genericCMYKCyan: CGFloat.random(in: 0..<1), magenta: 0.4, yellow: CGFloat.random(in: 0..<1), black: 0, alpha: 1 ))
            } else {
                 color = UIColor.init(hue: CGFloat.random(in: 0..<1), saturation: CGFloat.random(in: 0..<1), brightness: CGFloat.random(in: 0..<1), alpha: 1)
            }
        }
        let newItem=wheelElement(description: newElement, color: color)
        self.data.append(newItem)
        self.delegate?.modelUpdate()
    }
    
    func getAt(_ index: Int)->(String,UIColor)?{
        if(index<self.getCount()){
            //            print("index=\(index) text=\(self.data[index].description) color=\(self.data[index].color.hash)")
            return (self.data[index].description,self.data[index].color)
        }
        return nil
    }
    
    func setTextAt(_ index: Int, text: String){
        if(index<self.getCount()){
            self.data[index].description=text
        }
    }
    
    func getCount()->Int{
        return self.data.count
    }
    
    func deleteAt(_ index: Int){
        if(index<self.data.count){
            self.data.remove(at: index)
            self.delegate?.modelUpdate()
        }
    }
}
