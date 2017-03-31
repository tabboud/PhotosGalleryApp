//
//  ViewPhoto.swift
//  Photos Gallery App
//
//  Created by Tony on 7/7/14.
//  Copyright (c) 2014 Abbouds Corner. All rights reserved.
//
//  Updated for Xcode 6.0.1 GM 

import UIKit
import Photos

class ViewPhoto: UIViewController {
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var index: Int = 0
    
    //@Return to photos
    @IBAction func btnCancel(_ sender : AnyObject) {
        if let navController = self.navigationController {
            navController.popToRootViewController(animated: true)
        }
    }
    
    //@Export photo
    @IBAction func btnExport(_ sender : AnyObject) {
        print("Export")
    }
    
    //@Remove photo from Collection
    @IBAction func btnTrash(_ sender : AnyObject) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default,
            handler: {(alertAction)in
                PHPhotoLibrary.shared().performChanges({
                    //Delete Photo
                    if let request = PHAssetCollectionChangeRequest(for: self.assetCollection){
                        request.removeAssets(at: IndexSet([self.index]))
                    }
                },
                completionHandler: {(success, error)in
                    NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                    alert.dismiss(animated: true, completion: nil)
                    if(success){
                        // Move to the main thread to execute
                        DispatchQueue.main.async(execute: {
                            self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
                            if(self.photosAsset.count == 0){
                                print("No Images Left!!")
                                if let navController = self.navigationController {
                                    navController.popToRootViewController(animated: true)
                                }
                            }else{
                                if(self.index >= self.photosAsset.count){
                                    self.index = self.photosAsset.count - 1
                                }
                                self.displayPhoto()
                            }
                        })
                    }else{
                        print("Error: \(error)")
                    }
                })
            }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(alertAction)in
            //Do not delete photo
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet var imgView : UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true    //!!Added Optional Chaining
        
        self.displayPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func displayPhoto(){
        // Set targetSize of image to iPhone screen size
        let screenSize: CGSize = UIScreen.main.bounds.size
        let targetSize = CGSize(width: screenSize.width, height: screenSize.height)

        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: self.photosAsset[self.index], targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: {
            (result, info)->Void in
                self.imgView.image = result
        })
    }



}
