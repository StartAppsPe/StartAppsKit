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