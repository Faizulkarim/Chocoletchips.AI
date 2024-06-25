//
//  ImagePickerManager.swift
//  Plamedot
//
//  Created by Md Faizul karim on 2/2/23.
//

import UIKit
import Mantis

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    var picker = UIImagePickerController();
    var alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    
    override init(){
        super.init()
        
        alert.view.tintColor = UIColor.purple
        
        picker.allowsEditing = false
        
        picker.navigationBar.isTranslucent = false
        picker.navigationBar.barTintColor = UIColor.purple
        picker.navigationBar.tintColor = .white
        picker.modalPresentationStyle = .fullScreen
        picker.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)
        ]
    }
    
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
        self.viewController = viewController;
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
            UIAlertAction in
            self.openCamera()
        }
        
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default) {
            UIAlertAction in
            self.openGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".uppercased(), style: .cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController.present(alert, animated: true, completion: nil)
    }
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            
            let alert = UIAlertController(title: "Chocolatechips.ai", message: "You don't have camera", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                //Cancel Action
            }))
            alert.view.tintColor = UIColor.purple
            viewController!.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.viewController!.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let config = Mantis.Config()
        let cropViewController = Mantis.cropViewController(image: image,config: config)
        cropViewController.modalPresentationStyle = .currentContext
        cropViewController.delegate = self
        picker.present(cropViewController, animated: true)
        
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
 
        print("piked")
    }
    
}
extension ImagePickerManager : CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
        cropViewController.dismiss(animated: true) {
            self.picker.dismiss(animated: true)
            self.pickImageCallback?(cropped)
        }
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        picker.dismiss(animated: true)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: false, completion: nil)
        picker.dismiss(animated: true)
    }
    
    func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
        
    }
    
    func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
     
          print("End")
        
    }
    
   
}
