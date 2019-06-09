//
//  WebAPIHandler.swift
//  CrowdCounting
//
//  Created by Raelyn Lyu on 29/4/19.
//  Copyright © 2019 Raelyn Lyu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PhotosUI
import AlamofireImage

public struct WebAPIUrls{
    public static let IP = "35.189.17.138"//"127.0.0.1"//
    public static let baseURL = "http://\(IP):5000/"
    
    public static let uploadURL = baseURL + "up_photo"
    public static let fetchURL = baseURL + "download/"
}

public class WebAPIHandler {
    
    
    
    public static var shared = WebAPIHandler()

    private let jsonHeader:HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type":"application/json"
    ]
    
    var downloader:ImageDownloader!
    
    private var headerWithToken:HTTPHeaders?
    let imageCache = AutoPurgingImageCache()
    
    public let _httpManager : SessionManager =  {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            WebAPIUrls.IP: .disableEvaluation
            
        ]
        
        let sessionManager = SessionManager(
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return sessionManager
    }()
    
    private init(){
        let sessionManager = SessionManager(
            configuration: ImageDownloader.defaultURLSessionConfiguration(),
            serverTrustPolicyManager: ServerTrustPolicyManager(
                policies: [WebAPIUrls.IP: .disableEvaluation]
            )
        )
        downloader = ImageDownloader(sessionManager: sessionManager, downloadPrioritization: .lifo, maximumActiveDownloads: 10, imageCache: self.imageCache) //ImageDownloader(sessionManager: sessionManager)
        UIImageView.af_sharedImageDownloader = ImageDownloader(sessionManager: sessionManager)
    }

    
    
    public func upload(photo: UIImage,callback:@escaping ((DataResponse<Any>) -> Void) ){
        
        let imageData = photo.jpeg(.medium)!
        let rdm = String.randomStr(len: 10)
        UIFuncs.showLoadingLabel()
        
        _httpManager.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "photo",fileName:rdm+".jpeg",mimeType:"image/jpeg")
                
        },
            to: WebAPIUrls.uploadURL,
            method:HTTPMethod.post,
            headers:self.headerWithToken,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON{response in
                        UIFuncs.dismissLoadingLabel()
                        callback(response)

                    }
                case .failure(let encodingError):
                    UIFuncs.dismissLoadingLabel()
                    print(encodingError)
                }
        }
        )
        
    }
    

    
    public func fetchImage(url:String, identifier:String?, callback: @escaping (UIImage) -> Void ){
        
        let urlRequest = URLRequest(url: URL(string: WebAPIUrls.uploadURL + url)!)
        
        if let cachedImage = imageCache.image(withIdentifier: url){
            callback(cachedImage)
        }
        
        //        let downloader = ImageDownloader()
        downloader.download(urlRequest) { response in
            if let image = response.result.value {
                image.af_inflate()
                self.imageCache.add(image, withIdentifier: (response.request?.url?.lastPathComponent)!)
                //                self.imageCache.add(image, withIdentifier: identifier ?? "full")
                callback(image)
            }
        }
    }
    
}

extension String{
    static let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static func randomStr(len : Int) -> String{
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
}
