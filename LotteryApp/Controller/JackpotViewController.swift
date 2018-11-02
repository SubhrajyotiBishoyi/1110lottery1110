//
//  ViewController.swift
//  LotteryApp
//
//  Created by Subhrajyoti Bishoyi on 25/09/18.
//  Copyright © 2018 Subhrajyoti Bishoyi. All rights reserved.
//

import UIKit
import SQLite
import Alamofire
import SwiftyJSON
import ProgressHUD
import SwiftSoup

protocol CollectionViewCellDelegate: class {
    func collectionViewCell(_ cell: UICollectionViewCell, buttonTapped: UIButton)
}

class JackpotViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CollectionViewCellDelegate{

    @IBOutlet weak var jackpotCollectionView: UICollectionView!
    let powerBallData = PowerBallDataModel()
    let megaMillionData = MegaMIllionDataModel()
    
    var Jlogo = ""
    var JticketNo = ""
    var Jdate = ""
    
    var database: Connection!
    let PowerBallPrizeDB = Table("PowerBallPrizeAmountDB")
    let date = Expression<String>("date")
    let prizeAmount = Expression<String>("prizeAmount")
    let time = Expression<String>("time")
    let lotteryLogo = ["MegaMillions_Logo","power-ball"]
    let nextDrawing = "Next Drawing:"
    var dayInWeek = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProgressHUD.show()
        dataTable()
        loadData()
        jackpotCollectionView.dataSource = self
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
        let createTable = self.PowerBallPrizeDB.create(ifNotExists: true) { (table) in
                table.column(self.date)
                table.column(self.prizeAmount)
                table.column(self.time)
            }
            do{
                try self.database.run(createTable)
            }catch{
                print(error)
            }
            let deleteData = PowerBallPrizeDB.delete()
            do{
                try self.database.run(deleteData)
            }catch{
                print(error)
            }
    }
    
func loadData(){
        let url = "https://www.powerball.com/api/v1/estimates/powerball?_format=json"
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess{
                let pbPrizeJson : JSON = JSON(response.result.value!)
                let pbPrizeAmount = pbPrizeJson[0]["field_prize_amount"].stringValue
                let pbDate = pbPrizeJson[0]["field_next_draw_date"].stringValue
                let split = pbDate.components(separatedBy: "T")
                let dates = split[0].components(separatedBy: "-")
                let orgDate = dates[1] + "/" + dates[2] + "/" + dates[0]
                let cdate = orgDate
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "mm/dd/yyyy"
                let date = dateFormatter.date(from: orgDate)
             
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                self.dayInWeek = formatter.string(from: date!)
                
                let cPrizeAmount = pbPrizeAmount
                let ctime = "T" + split[1]
                let insert = self.PowerBallPrizeDB.insert(self.date <- cdate,self.prizeAmount <- cPrizeAmount, self.time <- ctime)
                do{
                    try self.database.run(insert)
                }
                catch{
                    print(error)
                }
                do {
                    let megaMillionData = try self.database.prepare(self.PowerBallPrizeDB)
                    for row in megaMillionData {
                        self.powerBallData.prizeAmount.append(row[self.prizeAmount])
                        self.powerBallData.date.append(row[self.date])
                        self.powerBallData.time.append(row[self.time])
                    }
                } catch {
                    print(error)
                }
                if(self.powerBallData.prizeAmount.count>0){
                    self.jackpotCollectionView.reloadData()
                }
            }
            else{
                print("Error: \(String(describing: response.result.error))")
            }
            
            ProgressHUD.dismiss()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lotteryLogo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = jackpotCollectionView.dequeueReusableCell(withReuseIdentifier: "jackpotCell", for: indexPath) as! JackpotCollectionViewCell
        cell.frame.size.width = UIScreen.main.bounds.width
        if(powerBallData.prizeAmount.count>0){
            if( (indexPath.row == 0) || (((indexPath.row)%2) == 0)){
                cell.lotteryLogo.image = UIImage(named: lotteryLogo[0])
                cell.prizeAmount.text = "$" + megaMillionData.getJackpotAmount() + " Million"
                cell.day.text = megaMillionData.getJackpotDay()
                cell.date.text = megaMillionData.getJackpotDate()
                Jlogo = lotteryLogo[indexPath.row]
                Jdate = megaMillionData.getJackpotDate()
            }
            else{
                cell.lotteryLogo.image = UIImage(named: lotteryLogo[1])
                cell.prizeAmount.text =  powerBallData.prizeAmount[0]
                cell.date.text = powerBallData.date[0]
                cell.day.text = dayInWeek
                Jlogo = lotteryLogo[indexPath.row]
                Jdate = powerBallData.date[0]
            }
        }
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.jackpotCollectionView.frame.width , height:160)
        
    }
    
    func collectionViewCell(_ cell: UICollectionViewCell, buttonTapped: UIButton) {
        let indexPath = self.jackpotCollectionView.indexPath(for: cell)
        collectionView(jackpotCollectionView, cellForItemAt: indexPath!)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTicketFrmJack"{
            let dvc = segue.destination as! TicketViewController
            dvc.identifier = "Jackpot"
            dvc.Jlogo = Jlogo
            dvc.Jdate = Jdate
        }
    }
   
}

