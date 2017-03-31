//
//  ViewController.swift
//  Photos Gallery App
//
//  Created by Tony on 7/7/14.
//  Copyright (c) 2014 Abbouds Corner. All rights reserved.
//
//  Updated to Xcode 6.0.1 GM

import UIKit
import Photos

let reuseIdentifier = "PhotoCell"
let albumName = "App Folder1"            //App specific folder name


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var albumFound : Bool = false
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var photosAsset: PHFetchResult<PHAsset>!
    var assetThumbnailSize:CGSize!
    
    @IBOutlet var noPhotosLabel: UILabel!
    
//Actions & Outlets
    @IBAction func btnCamera(_ sender : AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            //load the camera interface
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }else{
            //no camera available 
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {(alertAction)in
                alert.dismiss(animated: true, completion: nil)
                }))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    @IBAction func btnPhotoAlbum(_ sender : AnyObject) {
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
    }
    
    @IBOutlet var collectionView : UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
       
        if let first_Obj:AnyObject = collection.firstObject{
            //found the album
            self.albumFound = true
            self.assetCollection = first_Obj as! PHAssetCollection
        }else{
            //Album placeholder for the asset collection, used to reference collection in completion handler
            var albumPlaceholder:PHObjectPlaceholder!
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
                },
                completionHandler: {(success:Bool, error:Error?) in
                    if(success){
                        print("Successfully created folder")
                        self.albumFound = true
                        let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collection.firstObject!
                    }else{
                        print("Error creating folder")
                        self.albumFound = false
                    }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Get size of the collectionView cell for thumbnail image
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        
        //fetch the photos from collection
        self.navigationController?.hidesBarsOnTap = false   //!! Use optional chaining
        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)

        
        if let photoCnt = self.photosAsset?.count{
            if(photoCnt == 0){
                self.noPhotosLabel.isHidden = false
            }else{
                self.noPhotosLabel.isHidden = true
            }
        }
        self.collectionView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "viewLargePhoto"){
            if let controller:ViewPhoto = segue.destination as? ViewPhoto{
                if let cell = sender as? UICollectionViewCell{
                    if let indexPath: IndexPath = self.collectionView.indexPath(for: cell){
                        controller.index = indexPath.item
                        controller.photosAsset = self.photosAsset
                        controller.assetCollection = self.assetCollection
                    }
                }
            }
        }
    }
    
    

    
   
//UICollectionViewDataSource Methods (Remove the "!" on variables in the function prototype)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count: Int = 0
        if(self.photosAsset != nil){
            count = self.photosAsset.count
        }
        return count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: PhotoThumbnail = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoThumbnail
        
        //Modify the cell
        let asset: PHAsset = self.photosAsset[indexPath.item]

        // Create options for retrieving image (Degrades quality if using .Fast)
        //        let imageOptions = PHImageRequestOptions()
        //        imageOptions.resizeMode = PHImageRequestOptionsResizeMode.Fast
        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
                if let image = result {
                    cell.setThumbnailImage(image)
                }
            })
        return cell
    }
    
//UICollectionViewDelegateFlowLayout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 1
    }
    
    
    
//UIImagePickerControllerDelegate Methods
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        NSLog("in didFinishPickingMediaWithInfo")
        if let image: UIImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
    
            //Implement if allowing user to edit the selected image
            //let editedImage = info.objectForKey("UIImagePickerControllerEditedImage") as UIImage
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                PHPhotoLibrary.shared().performChanges({
                    let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset) {
                        albumChangeRequest.addAssets([assetPlaceholder!] as NSArray)
                    }
                    }, completionHandler: {(success, error)in
                        DispatchQueue.main.async(execute: {
                            NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                            picker.dismiss(animated: true, completion: nil)
                        })
                })
            
            })
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
}

