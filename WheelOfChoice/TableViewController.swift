//
//  TableViewController.swift
//  WheelOfChoice
//
//  Created by Anton Voloshuk on 16.02.2021.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let cellID="tableCellID"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.table.dequeueReusableCell(withIdentifier: self.cellID) as! TableCell
        cell.label.text="some text"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        present(UIViewController(), animated: true, completion: { })
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            
        }
    }
    

    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.backgroundColor=self.view.backgroundColor
        self.table.separatorStyle = .none
        self.table.delegate=self
        self.table.dataSource=self
        self.table.allowsSelection=true
        let uinib = UINib(nibName: "TableCell", bundle: .main)
        self.table.register(uinib, forCellReuseIdentifier: self.cellID)
        
    }
    



}
