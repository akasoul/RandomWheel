//
//  TableCellAddNew.swift
//  WheelOfChoice
//
//  Created by Anton Voloshuk on 17.02.2021.
//

import UIKit

class TableCellAddNew: UITableViewCell {
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = .clear
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
