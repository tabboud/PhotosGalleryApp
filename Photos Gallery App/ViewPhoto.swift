//
//  ViewPhoto.swift
//  Photos Gallery App
//
//  Created by Tony on 7/7/14.
//  Copyright (c) 2014 Abbouds Corner. All rights reserved.
//

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
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(alertAction)in
            //Delete Photo
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                request.removeAssets([self.photosAsset[self.index]])
                
                // Check if the user deleted the last photo, if so return to library
                if(self.photosAsset.count <= 1){    // Selected delete, and only 1 photo left
                    println("I AM HERE")
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }, completionHandler: {(success, error)in
                
                    NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    
                    self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
                    if(self.photosAsset.count == 0){
                        //no photos left
                        self.imgView.image = nil
                        println("No Images Left!!\nPhoto count = \(self.photosAsset.count)")
                        //!!Pop to root view controller OR return
                        return
                    }
                    if(self.index >= self.photosAsset.count){
                        self.index = self.photosAsset.count - 1
                    }
                    self.displayPhoto()
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
        let imageManager = PHImageManager.defaultManager()
        var ID = imageManager.requestImageForAsset(self.photosAsset[self.index] as PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit, options: nil, resultHandler: {
            (result, info)->Void in
                self.imgView.image = result
            })
    }



}
