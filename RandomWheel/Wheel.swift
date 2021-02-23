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
            //self.delegate?.modelUpdate()
        }
    }
    
    init( ) {
        
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
        })){
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
