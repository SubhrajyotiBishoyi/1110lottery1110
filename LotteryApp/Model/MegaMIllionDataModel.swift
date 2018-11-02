//
//  File.swift
//  LotteryApp
//
//  Created by Subhrajyoti Bishoyi on 25/09/18.
//  Copyright © 2018 Subhrajyoti Bishoyi. All rights reserved.
//

import UIKit
import SwiftSoup

class MegaMIllionDataModel {
    var dateInJackpot = String()
    var dayInJackpot = String()
    var date = [String]()
    var day = [String]()
    var ticketNo = [String]()
    var time = [String]()
    var prizeAmount : String = ""
    let url = URL(string: "http://www.megamillions.com")

    func getJackpotAmount() -> String{
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error as Any)
            }
            else{
                
                do {
                    let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    let doc: Document = try SwiftSoup.parse(html! as String)
        let div : String = try doc.getElementsByClass("home-next-drawing-estimated-jackpot-dollar-amount").text()
            self.prizeAmount = div
                    UserDefaults.standard.set(div, forKey: "prizeAmount")
        } catch {
        print("")
        }
            }
        }
        task.resume()
        let amount = UserDefaults.standard.string(forKey: "prizeAmount")
        return amount!
}
func getJackpotDay() -> String{
    let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
        do {
            let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            let doc: Document = try SwiftSoup.parse(html! as String)
            let day1 : String = try doc.getElementsByClass("home-next-drawing-date-top-day").text()
            self.dayInJackpot = day1
            let day = day1.components(separatedBy: " ")
            UserDefaults.standard.set(day[0], forKey: "day")
            UserDefaults.standard.set(day[1], forKey: "date")
        } catch {
            print("")
        }
    }
        task.resume()
        let dayJ = UserDefaults.standard.string(forKey: "day")
        return dayJ!
    }
    
    func getJackpotDate() -> String{
        let date = UserDefaults.standard.string(forKey: "date")
        return date!
    }
}
