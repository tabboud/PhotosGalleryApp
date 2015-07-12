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
    var photosAsset: PHFetchResult!
    var index: Int = 0
    
    //@Return to photos
    @IBAction func btnCancel(sender : AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true) //!!Added Optional Chaining
    }
    
    //@Export photo
    @IBAction func btnExport(sender : AnyObject) {
        println("Export")
    }
    
    //@Remove photo from Collection
    @IBAction func btnTrash(sender : AnyObject) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default,
            handler: {(alertAction)in
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    //Delete Photo
                    let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                    request.removeAssets([self.photosAsset[self.index]])
                    },
                    completionHandler: {(success, error)in
                        NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        if(success){
                            // Move to the main thread to execute
                            dispatch_async(dispatch_get_main_queue(), {
                                self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                                if(self.photosAsset.count == 0){
                                    println("No Images Left!!")
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                }else{
                                    if(self.index >= self.photosAsset.count){
                                        self.index = self.photosAsset.count - 1
                                    }
                                    self.displayPhoto()
                                }
                            })
                        }else{
                            println("Error: \(error)")
                        }
                })
            }))
        
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {(alertAction)in
            //Do not delete photo
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBOutlet var imgView : UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true    //!!Added Optional Chaining
        
        self.displayPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func displayPhoto(){
        // Set targetSize of image to iPhone screen size
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let targetSize = CGSizeMake(screenSize.width, screenSize.height)

        let imageManager = PHImageManager.defaultManager()
        if let asset = self.photosAsset[self.index] as? PHAsset{
            var ID = imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFit, options: nil, resultHandler: {
                (result, info)->Void in
                    self.imgView.image = result
            })
        }
    }



}
