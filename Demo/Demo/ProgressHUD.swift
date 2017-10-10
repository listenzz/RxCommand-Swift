//
//  ProgressHUD.swift
//  Demo
//
//  Created by Listen on 2017/10/11.
//  Copyright © 2017年 非非白. All rights reserved.
//

import Foundation
import PKHUD

class ProgressHUD {
    
    static var mapViews: [UIView : PKHUD] = [:]
    
    class func showMessage(_ msg: String, addTo view: UIView) {
        let hud = PKHUD()
        hud.contentView = PKHUDTextView(text: msg)
        hud.show(onView: view)
        hud.hide(afterDelay: 2)
    }
    
    class func showError(_ error: String?, addTo view: UIView) {
        let hud = PKHUD()
        hud.contentView = PKHUDTextView(text: error)
        hud.show(onView: view)
        hud.hide(afterDelay: 2)
    }
    
    class func showLoading(_ view: UIView) {
        let hud = PKHUD()
        hud.contentView = PKHUDProgressView()
        hud.show(onView: view)
        mapViews[view] = hud
    }
    
    class func hideLoading(_ view: UIView) {
        if let hud = mapViews[view] {
            hud.hide()
            mapViews[view] = nil
        }

    }
    
}
