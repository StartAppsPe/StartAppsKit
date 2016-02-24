//
//  LoadActionViewDelegates.swift
//  Pods
//
//  Created by Gabriel Lanata on 11/30/15.
//
//

import UIKit

extension UIActivityIndicatorView: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedValues: [LoadActionValues]) {
        switch loadAction.status {
        case .Loading: self.startAnimating()
        case .Ready:   self.stopAnimating()
        case .Paging:  self.startAnimating()
        }
    }
    
}

extension UIButton: LoadActionDelegate {
    
    public func loadActionUpdated<L: LoadActionType>(loadAction loadAction: L, updatedValues: [LoadActionValues]) {
        switch loadAction.status {
        case .Loading:
            activityIndicatorView?.startAnimating()
            userInteractionEnabled = false
            tempTitle = " "
        case .Ready, .Paging:
            activityIndicatorView?.stopAnimating()
            activityIndicatorView  = nil
            userInteractionEnabled = true
            if loadAction.error != nil {
                tempTitle = errorTitle ?? "Error"
            } else {
                tempTitle = nil
            }
        }
    }
    
}

