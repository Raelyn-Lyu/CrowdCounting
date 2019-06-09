//
//  UIfuncs.swift
//  CrowdCounting
//
//  Created by Raelyn Lyu on 29/4/19.
//  Copyright © 2019 Raelyn Lyu. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import SwiftMessages
import AudioToolbox
import FCAlertView

public class UIFuncs{
    static let ErrorSoundID:UInt32 = 1073
    
    static func setBorder(layer:CALayer, width:Float, cornerRadius:Float, color:CGColor){
        layer.borderWidth = CGFloat(width)
        layer.cornerRadius = CGFloat(cornerRadius)
        layer.borderColor = color
    }
    
    static func setBorder(views:[UIView], width:Float, cornerRadius:Float, color:CGColor){
        for v in views{
            v.layer.borderWidth = CGFloat(width)
            v.layer.cornerRadius = CGFloat(cornerRadius)
            v.layer.borderColor = color
        }
    }
    
    static func setWarning(layer:CALayer){
        layer.borderWidth = CGFloat(2)
        layer.borderColor = #colorLiteral(red: 1, green: 0.0862745098, blue: 0.3294117647, alpha: 1)
    }
    
    static func setNormal(layer:CALayer){
        layer.borderWidth = CGFloat(0)
}
    static func setupLoadingLabel(id:String, title:String, body:String, iconText:String = "⥁") -> (MessageView,SwiftMessages.Config){
        let loadingLabel = MessageView.viewFromNib(layout: .cardView)
        var config = SwiftMessages.Config()
        
        config.duration = .forever
        config.presentationStyle = .center
        config.presentationContext = .automatic
        
        
        loadingLabel.id = id
        loadingLabel.configureTheme(.info)
        loadingLabel.configureDropShadow()
        
        loadingLabel.configureContent(title: title, body: body, iconImage: nil, iconText: iconText, buttonImage: nil, buttonTitle: "OK", buttonTapHandler: { button in
            SwiftMessages.hide(id: loadingView.label.id)
        })
        
        return (loadingLabel,config)
    }
    
    static let loadingView:(label:MessageView,config:SwiftMessages.Config) = setupLoadingLabel(id:"loading", title: "Processing", body: "Please wait ...")
    
    
    static func showLoadingLabel(){
        SwiftMessages.show(config:loadingView.config, view: loadingView.label)
    }
    
    static func dismissLoadingLabel(){
        SwiftMessages.hide(id: loadingView.label.id)
    }
    
    enum BlockPopType{
        case caution
        case success
        case warning
        case process
    }
    
    static func popUp(title:String, info:String, type:BlockPopType,sender:UIViewController,callback:@escaping ()->Void){
        let alert = FCAlertView()
        alert.doneBlock = callback
        switch type{
        case .caution:
            alert.makeAlertTypeCaution()
        case .success:
            alert.makeAlertTypeSuccess()
        case .warning:
            alert.makeAlertTypeWarning()
        case .process:
            alert.makeAlertTypeProgress()
        }
        
        alert.showAlert(inView: sender,
                        withTitle: title,
                        withSubtitle: info,
                        withCustomImage: nil,
                        withDoneButtonTitle: nil,
                        andButtons: nil)
    }
}
