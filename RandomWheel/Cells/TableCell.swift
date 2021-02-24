//
//  TableCell.swift
//  WheelOfChoice
//
//  Created by Anton Voloshuk on 16.02.2021.
//

import UIKit

class TableCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var field: CustomTextField!{
        didSet{
            print("Cell text")
        }
    }
    
    var rectClr: UIColor?
    private let rectCornerRadius: CGFloat=30
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor=UIColor.clear
        self.view.backgroundColor=self.rectClr ?? .clear
        self.view.layer.cornerRadius=self.rectCornerRadius
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func calculateFontSize(){
        if(self.field == nil){
            return
        }
        if((self.field.text ?? "") == ""){
            return
        }
        var fontSize:CGFloat=1
        let maxSize:CGFloat = 25
        var size: CGSize = ((self.field.text ?? "") as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)])
        while(size.width < self.field.frame.width && size.height<self.field.frame.height && fontSize < maxSize){
            size = ((self.field.text ?? "") as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)])
            fontSize+=0.5
        }
        self.field.font=UIFont.systemFont(ofSize: fontSize)
    }
    
}

class CustomTextField: UITextField{
    override var canBecomeFirstResponder: Bool{
        get{
            return true
        }
    }
}
