//
//  ImageCollectionViewController.swift
//  PG_Test
//
//  Created by Sakshi Jain on 25/11/17.
//  Copyright © 2017 Sakshi. All rights reserved.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "imageCell"

class ImageCollectionViewController: UICollectionViewController {

    var imageArray : ImageModelCollection?

    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ImageCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if let count = self.imageArray?.imgArray.count{
            return count
        }
        else
        {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ImageCollectionViewCell
        
        let image : ImageModel
        image = (self.imageArray?.imgArray[indexPath.item] as? ImageModel)!
        cell.backgroundColor = UIColor.white
       
        if let url = image.largeImageURL
        {
            cell.photoImageView.sd_setImage(with: url as URL)
        }
        
        return cell
    }
}

extension ImageCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension ImageCollectionViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        NetworkCall.sharedNetworkManager.getServerCall(getApi: eWebRequestName.eRequestTypeSearch, params: textField.text) { (responseDict) in
            activityIndicator.removeFromSuperview()
        
            self.imageArray = ImageModelCollection(json: responseDict)
        
            //print(self.imageArray?.imgArray as Any)
            self.collectionView?.reloadData()
        }
        
        textField.text = nil
        textField.resignFirstResponder()
    
        return true
    }
}
