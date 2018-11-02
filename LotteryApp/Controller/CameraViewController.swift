//
//  CameraViewController.swift
//  LotteryApp
//
//  Created by Subhrajyoti Bishoyi on 29/09/18.
//  Copyright © 2018 Subhrajyoti Bishoyi. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        imagePicker.delegate = self
    }

    @IBAction func selectImageTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "", message: "Choose a picture", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { ACTION in self.openGallery()}))
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { ACTION in self.openCamera()}))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    func openGallery(){
        imagePicker.sourceType  = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .overFullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera(){
        imagePicker.sourceType  = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .overFullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    var unchecked = true
    @IBAction func checkboxClicked(_ sender: UIButton) {
        if unchecked {
            sender.setImage(UIImage(named:"checked_Box"), for: .normal)
            unchecked = false
        }
        else {
            sender.setImage( UIImage(named:"unChecked_Box"), for: .normal)
            unchecked = true
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
