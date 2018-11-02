//
//  JackpotCollectionViewCell.swift
//  LotteryApp
//
//  Created by Subhrajyoti Bishoyi on 26/09/18.
//  Copyright © 2018 Subhrajyoti Bishoyi. All rights reserved.
//

import UIKit

class JackpotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var lotteryLogo: UIImageView!
    @IBOutlet weak var nextDrawing: UILabel!
    @IBOutlet weak var prizeAmount: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var date: UILabel!
     var delegate: CollectionViewCellDelegate?

    @IBAction func downloadTapped(_ sender: UIButton) {
    }
    @IBAction func cameraTapped(_ sender: UIButton) {
        
    }
    @IBAction func addTapped(_ sender: UIButton) {
        self.delegate?.collectionViewCell(self, buttonTapped: addBtn)

    }
}

