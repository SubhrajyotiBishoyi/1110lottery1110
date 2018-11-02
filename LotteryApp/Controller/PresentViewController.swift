//
//  PresentViewController.swift
//  LotteryApp
//
//  Created by Subhrajyoti Bishoyi on 28/09/18.
//  Copyright © 2018 Subhrajyoti Bishoyi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SQLite
import ProgressHUD

class PresentViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CollectionViewCellDelegate{
    
    let megaMillionData = MegaMIllionDataModel()
    let powerBallData = PowerBallDataModel()
    
    var database: Connection!
    let MegaMillionDB = Table("MegaMillionDB")
    let PowerBallDB = Table("PowerBallDB")
    let date = Expression<String>("date")
    let ticketNo = Expression<String>("ticketNo")
    let time = Expression<String>("time")
    
    let lotteryLogo = ["MegaMillions_Logo","power-ball"]
    var count = 10
  
    @IBOutlet weak var presentCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProgressHUD.show()
        dataTable()
        loadMegaData()
        loadPowerData()
        presentCollectionView.delegate = self
        presentCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
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
        let createTable = self.MegaMillionDB.create(ifNotExists: true) { (table) in
            table.column(self.date)
            table.column(self.ticketNo)
            table.column(self.time)
        }
        let createPBTable = self.PowerBallDB.create(ifNotExists: true) { (table) in
            table.column(self.date)
            table.column(self.ticketNo)
            table.column(self.time)
        }
        do{
            try self.database.run(createTable)
            try self.database.run(createPBTable)
        }catch{
            print(error)
        }
        let deleteData = MegaMillionDB.delete()
        let dltData = PowerBallDB.delete()
        do{
            try self.database.run(deleteData)
            try self.database.run(dltData)
        }catch{
            print(error)
        }
    }
    
    func loadMegaData() {
        let url = "https://data.ny.gov/api/views/5xaw-6ayf/rows.json?accessType=DOWNLOAD"
        Alamofire.request(url, method: .get).responseJSON { (response) in
            if response.result.isSuccess{
                let megaMillJson : JSON = JSON(response.result.value!)
                let megaMillJsonData = megaMillJson["data"].arrayObject
                let size = megaMillJsonData?.count
                self.megaMillionData.date = []
                self.megaMillionData.time = []
                self.megaMillionData.ticketNo = []
                for i in stride(from: size!-1, through: 0, by: -1){
                    let subArray = megaMillJsonData![i] as AnyObject
                    let count = subArray.count
                    let t1 = subArray[count!-3] as AnyObject
                    let t2 = subArray[count!-2] as AnyObject
                    let ticket = (t1 as! String) + " " + (t2 as! String)
                    
                    let dateTime = subArray[count!-4] as AnyObject
                    let split = dateTime.components(separatedBy: "T")
                    let date = split[0]
                    let time = "T" + split[1]
                    let dsplit = date.components(separatedBy: "-")
                    let year = dsplit[0]
                    if(year < "2018"){
                        break
                    }
                    
                    let cdate = date
                    let cticket = ticket
                    let ctime = time
                    let insert = self.MegaMillionDB.insert(self.date <- cdate,self.ticketNo <- cticket, self.time <- ctime)
                    do{
                        try self.database.run(insert)
                    }
                    catch{
                        print(error)
                    }
                    do {
                        let megaMillionData = try self.database.prepare(self.MegaMillionDB)
                        for row in megaMillionData {
                            self.megaMillionData.date.append(row[self.date])
                            self.megaMillionData.time.append(row[self.time])
                            self.megaMillionData.ticketNo.append(row[self.ticketNo])
                        }
                    } catch {
                        print(error)
                    }
                }
                if(self.megaMillionData.date.count>0){
                    self.presentCollectionView.reloadData()
                }
            }
            else{
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    func loadPowerData(){
        let url2 = "https://data.ny.gov/api/views/d6yy-54nr/rows.json?accessType=DOWNLOAD"
        Alamofire.request(url2, method: .get).responseJSON { (response) in
            if response.result.isSuccess{
                let powerBallJson : JSON = JSON(response.result.value!)
                let powerBallJsonData = powerBallJson["data"].arrayObject
                let size = powerBallJsonData?.count
                
                self.powerBallData.date = []
                self.powerBallData.time = []
                self.powerBallData.ticketNo = []
                for i in stride(from: size!-1, through: 0, by: -1){
                    let subArray = powerBallJsonData![i] as AnyObject
                    let count1 = subArray.count
                    let ticket = subArray[count1!-2] as AnyObject
                    let dateTime = subArray[count1!-3] as AnyObject
                    let split = dateTime.components(separatedBy: "T")
                    let date = split[0]
                    let time = "T" + split[1]
                    let dsplit = date.components(separatedBy: "-")
                    let year = dsplit[0]
                    if(year < "2018"){
                        break
                    }
                    
                    let cdate = date
                    let cticket = ticket as! String
                    let ctime = time
                    let insertClm = self.PowerBallDB.insert(self.date <- cdate,self.ticketNo <- cticket, self.time <- ctime)
                    do{
                        try self.database.run(insertClm)
                    }
                    catch{
                        print(error)
                    }
                    do {
                        let powerBallData = try self.database.prepare(self.PowerBallDB)
                        for row in powerBallData {
                            self.powerBallData.date.append(row[self.date])
                            self.powerBallData.time.append(row[self.time])
                            self.powerBallData.ticketNo.append(row[self.ticketNo])
                        }
                    } catch {
                        print(error)
                    }
                }
                if(self.powerBallData.date.count>0){
                    self.presentCollectionView.reloadData()
                }
            }
            else{
                print("Error: \(String(describing: response.result.error))")
            }
        
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = presentCollectionView.dequeueReusableCell(withReuseIdentifier: "presentCell", for: indexPath) as! PresentCollectionViewCell
        if(megaMillionData.time.count>0 && powerBallData.time.count>0){
         if( (indexPath.row == 0) || (((indexPath.row)%2) == 0)){
            cell.lotteryLogo.image = UIImage(named: lotteryLogo[0])
            cell.time.text = megaMillionData.time[indexPath.row]
            cell.date.text = megaMillionData.date[indexPath.row]
            cell.ticketNo.text = megaMillionData.ticketNo[indexPath.row]
        }
         else{
            cell.lotteryLogo.image = UIImage(named: lotteryLogo[1])
            cell.time.text = powerBallData.time[indexPath.row]
            cell.date.text = powerBallData.date[indexPath.row]
            cell.ticketNo.text = powerBallData.ticketNo[indexPath.row]
        }
            ProgressHUD.dismiss()
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            if(count < 22){
                count += 6
                self.presentCollectionView.reloadData()
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.presentCollectionView.frame.width , height:150)
        
    }
    
    func collectionViewCell(_ cell: UICollectionViewCell, buttonTapped: UIButton) {
        let indexPath = self.presentCollectionView.indexPath(for: cell)
        collectionView(presentCollectionView, cellForItemAt: indexPath!)
    }
    
}
