//
//  TableViewController.swift
//  WheelOfChoice
//
//  Created by Anton Voloshuk on 16.02.2021.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,WheelDelegate {
    
    private let cellID="tableCellID"
    private let cellAddNewID="tableCellAddNewID"
    private var model: Wheel?
    private var selectedRow: IndexPath?
    private var showKeyboard=false
    @IBOutlet weak var table: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let out = (self.model?.getCount() ?? 0) + 1
        return out
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < self.model?.getCount() ?? 1){
            let cell = self.table.dequeueReusableCell(withIdentifier: self.cellID) as! TableCell
            (cell.field.text, cell.rectClr) = self.model?.getAt(indexPath.row) ?? ("", .clear)
            cell.calculateFontSize()
            cell.setNeedsDisplay()
            return cell
        }
        else{
            let cell = self.table.dequeueReusableCell(withIdentifier: self.cellAddNewID) as! TableCellAddNew
            cell.button.addTarget(self, action: #selector(self.buttonTap), for: .touchDown)
            cell.setNeedsDisplay()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < (self.model?.getCount() ?? 0){
            
            self.selectedRow=indexPath
            let cell = (tableView.cellForRow(at: indexPath) as! TableCell)
            cell.field.delegate=self
            if(cell.field.isFirstResponder){
                if(cell.field.canResignFirstResponder){
                    cell.field.resignFirstResponder()
                }
            }
            else{
                if(cell.field.canBecomeFirstResponder){
                    cell.field.becomeFirstResponder()
                    cell.field.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){            
            self.model?.deleteAt(indexPath.row)
        }
    }
    
    @objc func buttonTap(){
        self.model?.addNew("")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        if(self.selectedRow != nil){
            self.model?.setTextAt((self.selectedRow?.row ?? 0), text: (textField.text ?? ""))
            let cell = (self.table.cellForRow(at: self.selectedRow!) as! TableCell)
            cell.calculateFontSize()
        }
    }
    
    func modelUpdate() {
        self.table.reloadData()
        self.table.draw(self.table.frame)
//        let bottomIndex = IndexPath(item: (self.model?.getCount() ?? 1), section: 0)
//        self.table.scrollToRow(at: bottomIndex, at: .bottom, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tmp=(self.parent as? TabBarController){
            self.model = tmp.model
            self.model?.delegate=self
        }
        
        self.table.backgroundColor=self.view.backgroundColor
        self.table.separatorStyle = .none
        self.table.delegate=self
        self.table.dataSource=self
        self.table.allowsSelection=true
        let uinib1 = UINib(nibName: "TableCell", bundle: .main)
        self.table.register(uinib1, forCellReuseIdentifier: self.cellID)
        
        let uinib2 = UINib(nibName: "TableCellAddNew", bundle: .main)
        self.table.register(uinib2, forCellReuseIdentifier: self.cellAddNewID)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.model?.delegate=self
        self.table.reloadData()
    }
    
    
}
