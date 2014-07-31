//
//  ViewController.swift
//  Photos Gallery App
//
//  Created by Tony on 7/7/14.
//  Copyright (c) 2014 Abbouds Corner. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "PhotoCell"
let albumName = "My App"            //App specific folder name


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult!
    
    
//Actions & Outlets
    @IBAction func btnCamera(sender : AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            //load the camera interface
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            //no camera available 
            var alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
                }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    @IBAction func btnPhotoAlbum(sender : AnyObject) {
            var picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.delegate = self
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBOutlet var collectionView : UICollectionView!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        if(collection.firstObject){
            //found the album
            self.albumFound = true
            self.assetCollection = collection.firstObject as PHAssetCollection
        }else{
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                },
                completionHandler: {(success:Bool, error:NSError!)in
                    NSLog("Creation of folder -> %@", (success ? "Success":"Error!"))
                    self.albumFound = (success ? true:false)
                })
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //fetch the photos from collection
        self.navigationController.hidesBarsOnTap = false
        self.photosAsset = PHAsset.fetchAssetsInAssetCollection(self.assetCollection, options: nil)
        
        //TODO: Insert a label that says 'No Photos' when empty
        
        self.collectionView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if(segue.identifier as String == "viewLargePhoto"){
            let controller:ViewPhoto = segue.destinationViewController as ViewPhoto
            let indexPath: NSIndexPath = self.collectionView.indexPathForCell(sender as UICollectionViewCell)
            controller.index = indexPath.item
            controller.photosAsset = self.photosAsset
            controller.assetCollection = self.assetCollection
        }
    }
    
    
    
//UICollectionViewDataSource Methods
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int{
        var count: Int = 0
        if(self.photosAsset != nil){
            count = self.photosAsset.count
        }
        return count;
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell!{
        let cell: PhotoThumbnail = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as PhotoThumbnail
        
        //Modify the cell
        let asset: PHAsset = self.photosAsset[indexPath.item] as PHAsset
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: nil, resultHandler: {(result, info)in
                cell.setThumbnailImage(result)
            })

        return cell
    }
    
//UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 4
    }
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
    
    
    
    
    
//UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!){
        let image = info.objectForKey("UIImagePickerControllerOriginalImage") as UIImage
        
        //Implement if allowing user to edit the selected image
        //let editedImage = info.objectForKey("UIImagePickerControllerEditedImage") as UIImage
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection, assets: self.photosAsset)
            albumChangeRequest.addAssets([assetPlaceholder])
            }, completionHandler: {(success, error)in
                NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                picker.dismissViewControllerAnimated(true, completion: nil)
            })
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController!){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    


}

