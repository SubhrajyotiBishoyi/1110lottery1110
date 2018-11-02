//
//  TicketViewController.swift
//  LotteryApp
//
//  Created by Subhrajyoti Bishoyi on 28/09/18.
//  Copyright © 2018 Subhrajyoti Bishoyi. All rights reserved.
//

import UIKit
import SQLite

class TicketViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var textfield6: UITextField!
    @IBOutlet weak var textfield5: UITextField!
    @IBOutlet weak var textfield4: UITextField!
    @IBOutlet weak var textfield3: UITextField!
    @IBOutlet weak var textfield2: UITextField!
    @IBOutlet weak var textfield: UITextField!
    
    var identifier = ""
    var Jlogo = ""
    var Jdate = ""
    var checked = 0
    
    var database: Connection!
    let TicketNos = Table("TicketNo")
    let date = Expression<String>("date")
    let ticketNo = Expression<String>("ticketNo")
    let logo = Expression<String>("logo")
    let megaplier = Expression<Int>("megaplier")

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTable()
        self.tabBarController?.tabBar.isHidden = true
        textfield.delegate = self
        textfield2.delegate = self
        textfield3.delegate = self
        textfield4.delegate = self
        textfield5.delegate = self
        textfield6.delegate = self
        
        textfield.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfield2.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfield3.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfield4.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfield5.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textfield6.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text!
        if text.utf16.count == 0 {
            switch textField {
            case textfield2:
                textfield.becomeFirstResponder()
            case textfield3:
                textfield2.becomeFirstResponder()
            case textfield4:
                textfield3.becomeFirstResponder()
            case textfield5:
                textfield4.becomeFirstResponder()
            case textfield6:
                textfield5.becomeFirstResponder()
            default:
                break
            }
        }
        else if text.utf16.count == 2 {
            switch textField {
            case textfield:
                textfield2.becomeFirstResponder()
            case textfield2:
                textfield3.becomeFirstResponder()
            case textfield3:
                textfield4.becomeFirstResponder()
            case textfield4:
                textfield5.becomeFirstResponder()
            case textfield5:
                textfield6.becomeFirstResponder()
            case textfield6:
                textfield6.resignFirstResponder()
            default:
                break
            }
        }
    }
    func dataTable() {
        do{
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("Lottery").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        }
        catch{
            print(error)
        }
        let createTable = self.TicketNos.create(ifNotExists: true) { (table) in
            table.column(self.ticketNo)
            table.column(self.date)
            table.column(self.logo)
            table.column(self.megaplier)
        }
        do{
            try self.database.run(createTable)
        }catch{
            print(error)
        }
//        let deleteData = TicketNos.delete()
//        do{
//            try self.database.run(deleteData)
//        }catch{
//            print(error)
//        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 2
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
     var unchecked = true
    @IBAction func checkboxClicked(_ sender: UIButton) {
            if unchecked {
                sender.setImage(UIImage(named:"checked_Box"), for: .normal)
                unchecked = false
                checked = 1
            }
            else {
                sender.setImage( UIImage(named:"unChecked_Box"), for: .normal)
                unchecked = true
                checked = 0
            }
    }
    @IBAction func submitTicket(_ sender: UIButton) {
        if(textfield.text?.count != 2 || textfield2.text?.count != 2 || textfield3.text?.count != 2){
            let alertControl = UIAlertController(title: "", message: "Please Enter a Valid Ticket No.", preferredStyle: .alert)
            alertControl.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertControl,animated: true,completion: nil)
        }
        if(textfield4.text?.count != 2 || textfield5.text?.count != 2 || textfield6.text?.count != 2){
            let alertControl = UIAlertController(title: "", message: "Please Enter a Valid Ticket No.", preferredStyle: .alert)
            alertControl.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertControl,animated: true,completion: nil)
        }
        if(identifier == "Jackpot"){
        let alertControl = UIAlertController(title: "", message: "Thank You. Your Lottery No. is stored.", preferredStyle: .alert)
        alertControl.addAction(UIAlertAction(title: "Ok", style: .default, handler: { ACTION in         _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alertControl,animated: true,completion: nil)
        }
        else{
            let alertControl = UIAlertController(title: "", message: "Thank You. Your Lottery No. is stored.", preferredStyle: .alert)
            alertControl.addAction(UIAlertAction(title: "Ok", style: .default, handler: { ACTION in         _ = self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertControl,animated: true,completion: nil)
        }
        let ticket = textfield.text! + " " + textfield2.text! + " " + textfield3.text! + " " + textfield4.text! + " " + textfield5.text! + " " + textfield6.text!
        let insert = self.TicketNos.insert(self.date <- Jdate,self.ticketNo <- ticket, self.logo <- Jlogo,self.megaplier <- checked)
                do{
                    try self.database.run(insert)
                }
                catch{
                    print(error)
                }
        
                do {
                    let TicketInfo = try self.database.prepare(self.TicketNos)
                    for row in TicketInfo {
                      print(row[self.ticketNo])
                      print(row[self.date])
                      print(row[self.logo])
                      print(row[self.megaplier])
                    }
                } catch {
                    print(error)
                }
    }
    
}
