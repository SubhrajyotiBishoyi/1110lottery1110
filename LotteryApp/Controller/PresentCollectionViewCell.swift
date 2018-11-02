//
//  PresentCollectionViewCell.swift
//  LotteryApp
//
//  Created by Subhrajyoti Bishoyi on 28/09/18.
//  Copyright © 2018 Subhrajyoti Bishoyi. All rights reserved.
//

import UIKit

class PresentCollectionViewCell: UICollectionViewCell {
     @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var lotteryLogo: UIImageView!
    
    @IBOutlet weak var winningNo: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var ticketNo: UILabel!
    @IBAction func downloadTapped(_ sender: UIButton) {
    }
    @IBAction func cameraTapped(_ sender: UIButton) {
    }
    @IBAction func addTapped(_ sender: UIButton) {
    }

}
