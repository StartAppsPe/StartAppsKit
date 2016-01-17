//
//  SATableViewCells.swift
//  StartAppsCommon
//
//  Created by Gabriel Lanata on 10/25/14.
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version 1.0
//

/*import UIKit

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Info Table View Cell

public class LoadingStatusInfoGroup {
    public var loadingInfo = LoadingStatusInfo(title: "Actualizando", showActivityIndicator: true)
    public var emptyInfo   = LoadingStatusInfo(title: "No hay objetos", detail: "No se encontró ningún objeto")
    public var errorInfo   = LoadingStatusInfo(title: "Error", detail: "Se produjo un error desconocido", button: "¿Reintentar?", buttonColor: UIColor(red: 0.90, green: 0.70, blue: 0.09, alpha: 1.0))
    
    public init(loadingInfo: LoadingStatusInfo? = nil, emptyInfo: LoadingStatusInfo? = nil, errorInfo: LoadingStatusInfo? = nil) {
        if loadingInfo != nil { self.loadingInfo = loadingInfo! }
        if emptyInfo   != nil { self.emptyInfo   = emptyInfo!   }
        if errorInfo   != nil { self.errorInfo   = errorInfo!   }
    }
}

public class LoadingStatusInfo {
    public var title: String?
    public var detail: String?
    public var button: String?
    public var buttonColor: UIColor?
    public var image: UIImage?
    public var showActivityIndicator = false
    public init(title: String? = nil, detail: String? = nil, button: String? = nil, buttonColor: UIColor? = nil, image: UIImage? = nil, showActivityIndicator: Bool = false) {
        self.title = title
        self.detail = detail
        self.button = button
        self.buttonColor = buttonColor
        self.image = image
        self.showActivityIndicator = showActivityIndicator
    }
}

public protocol InfoTableViewCellDelegate {
    func infoTableViewCellLoadingButtonPressed()
    func infoTableViewCellEmptyButtonPressed()
    func infoTableViewCellErrorButtonPressed()
}

public class InfoTableViewCell: UITableViewCell {
    
    @IBOutlet public weak var titleLabel:      UILabel!
    @IBOutlet public weak var detailLabel:     UILabel!
    @IBOutlet public weak var optionButton:    UIButton!
    @IBOutlet public weak var centerImageView: UIImageView?
    @IBOutlet public weak var activityIndicatorView: UIActivityIndicatorView!
    
    public var loadingStatusInfoGroup = LoadingStatusInfoGroup()
    
    public var delegate: InfoTableViewCellDelegate?
    public var loadingStatus: LoadingStatus = .None {
        didSet {
            var loadingStatusInfo: LoadingStatusInfo!
            switch loadingStatus {
            case .Loading, .Reloading, .Paging:   loadingStatusInfo = loadingStatusInfoGroup.loadingInfo
            case .Empty,   .Loaded:               loadingStatusInfo = loadingStatusInfoGroup.emptyInfo
            case .Error, .LoadedWithError, .None: loadingStatusInfo = loadingStatusInfoGroup.errorInfo
            }
            titleLabel.text = loadingStatusInfo.title
            optionButton.title = loadingStatusInfo.button
            optionButton.backgroundColor = loadingStatusInfo.buttonColor ?? UIColor.grayColor()
            optionButton.processingStatus = .Ready
            optionButton.hidden = (loadingStatusInfo.button == nil)
            centerImageView?.image = loadingStatusInfo.image
            switch loadingStatus {
            case .Error(let error): detailLabel.text = error?.localizedDescription ?? loadingStatusInfo.detail
            default: detailLabel.text = loadingStatusInfo.detail
            }
            if loadingStatusInfo.showActivityIndicator {
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    @IBAction public func optionButtonPressed(sender: AnyObject) {
        if let delegate = delegate {
            switch loadingStatus {
            case .Loading, .Reloading, .Paging:
                delegate.infoTableViewCellLoadingButtonPressed()
            case .Empty, .Loaded:
                delegate.infoTableViewCellEmptyButtonPressed()
            case .Error, .LoadedWithError, .None:
                delegate.infoTableViewCellErrorButtonPressed()
            }
            optionButton.processingStatus = .Processing
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
    }
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Table View Cell Height Extension

public class PagingTableViewCell: UITableViewCell {
    
    public var activityIndicatorView: UIActivityIndicatorView?
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if activityIndicatorView == nil {
            activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            activityIndicatorView!.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
            activityIndicatorView!.color = UIColor.blackColor()
            activityIndicatorView!.startAnimating()
            self.addSubview(activityIndicatorView!)
        }
        backgroundColor = UIColor.clearColor()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(style: .Default, reuseIdentifier: nil)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicatorView?.startAnimating()
    }
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Table View Cell Height Extension

extension UITableViewCell {
    
    public func autoLayoutHeight(tableView: UITableView? = nil) -> CGFloat {
        if let tableView = tableView { // where frame.size.width == 0 {
            frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 9999)
            contentView.frame = frame
        }
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height+1
    }
    
}
*/

