//
//  NLGlobalUtils.swift
//  LiveEncode
//
//  Created by neulion on 8/17/17.
//  Copyright © 2017 NeuLion. All rights reserved.
//

import UIKit
import Photos

struct StoragePath{
    static let OriginalPhotoPath:String! = {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
    }()
}
class NLGlobalUtils: NSObject {
    
    public class func getPhotoCollectionRequest(_ name:String) -> PHAssetCollectionChangeRequest{
        var collectionExist = false
        let results = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options:nil)
        for i in 0 ..< results.count{
            let item = results[i]
            if (item.localizedTitle?.contains(name))!{
                collectionExist = true
                return PHAssetCollectionChangeRequest.init(for: item)!
            }
        }
        if !collectionExist{
            return PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        }
    }
    
    public class func saveVideoAsset( withPath:String!, groupName:String!){
        let photoLibrary =
        PHPhotoLibrary.shared().performChanges({
           let request = NLGlobalUtils.getPhotoCollectionRequest(groupName)
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: withPath))
            if let placeHolder = assetRequest?.placeholderForCreatedAsset {
                let assetArray:NSArray = [placeHolder]
                request.addAssets(assetArray)
            }
        }) { (sucess, error) in

        }
    }
}
