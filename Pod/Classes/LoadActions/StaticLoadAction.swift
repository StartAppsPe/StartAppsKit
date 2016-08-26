//
//  StaticLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 12/11/15.
//
//

import Foundation

import UIKit

public class StaticLoadAction: LoadAction<[StaticTableItemProtocol]> {
    
    public typealias StaticItemsResultType    = Result<[StaticTableItemProtocol], ErrorType>
    public typealias StaticItemsResultClosure = (result: StaticItemsResultType) -> Void
    public typealias StaticItemsResult        = (completion: StaticItemsResultClosure) -> Void
    
    /**
     Quick initializer with all closures
     
     - parameter load: Closure to load from web, must call result closure when finished
     - parameter delegates: Array containing objects that react to updated data
     */
    public init(
        staticItems: StaticItemsResult,
        delegates:   [LoadActionDelegate] = [],
        dummy:       (() -> ())? = nil)
    {
        super.init(
            load: staticItems,
            delegates: delegates
        )
    }
    
}


// Section Management
//public class StaticItemSection {
//    var header:  String?
//    var items: [StaticTableItem]!
//    func append(item: StaticTableItem) {
//        items.append(item)
//    }
//    init(header: String? = nil, items: [StaticTableItem]? = nil) {
//        self.header = header
//        self.items = items ?? [StaticTableItem]()
//    }
//}
//public func += (inout left: [StaticItemSection], right: StaticItemSection?) {
//    if let right = right { left.append(right) }
//}
//public func += (inout left: StaticItemSection, right: StaticTableItem?) {
//    if let right = right { left.append(right) }
//}



// Default cell
public protocol StaticTableItemProtocol {
    
}

public class StaticTableItem<C: UITableViewCell>: StaticTableItemProtocol {
    public var cellIdentifier: String
    public var customization: ((cell: C) -> Void)?
    public var onSelection:   ((cell: C) -> Void)?
    public var onAction:      ((cell: C) -> Void)?
    public init(cellIdentifier: String) {
        self.cellIdentifier = cellIdentifier
    }
    public func setCustomization(customization: ((cell: C) -> Void)?) {
        self.customization = customization
    }
    public func setOnSelection(onSelection: ((cell: C) -> Void)?) {
        self.onSelection = onSelection
    }
    public func setOnAction(onAction: ((cell: C) -> Void)?) {
        self.onAction = onAction
    }
}

public class StaticTableViewCell: UITableViewCell {
    public class func defaultIdentifier() -> String { return "StaticTableViewCell" }
    public var tableItem: StaticTableItem<UITableViewCell>!
    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        tableItem.onSelection?(cell: self)
    }
}
public class TitleStaticTableViewCell: StaticTableViewCell {
    public override class func defaultIdentifier() -> String { return "TitleStaticTableViewCell" }
    @IBOutlet public weak var titleLabel: UILabel?
}
public class TextStaticTableViewCell: TitleStaticTableViewCell {
    public override class func defaultIdentifier() -> String { return "TextStaticTableViewCell" }
    @IBOutlet public weak var contentLabel: UILabel?
}
public class PictureStaticTableViewCell: TextStaticTableViewCell {
    public override class func defaultIdentifier() -> String { return "PictureStaticTableViewCell" }
    @IBOutlet public weak var pictureView: UIImageView?
}

public class ButtonStaticTableViewCell: PictureStaticTableViewCell {
    public override class func defaultIdentifier() -> String { return "ButtonStaticTableViewCell" }
    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        tableItem.onAction?(cell: self)
    }
}

public class SwitchStaticTableViewCell: TextStaticTableViewCell {
    public override class func defaultIdentifier() -> String { return "SwitchStaticTableViewCell" }
    @IBOutlet weak var switchView: UISwitch?
    public override var tableItem: StaticTableItem<UITableViewCell>! {
        didSet {
            switchView?.setAction(controlEvents: .ValueChanged, action: { (sender) in
                self.tableItem.onAction?(cell: self)
            })
        }
    }
}

//// Check Cell
//public class SACheckTableObject: SATitleTableObject {
//    public var checkOn:  Bool
//    public var onAction: ((sender: SACheckTableViewCell) -> Void)
//    init(cellIdentifier: String = "CheckCell", title: String?, checkOn: Bool,
//         customization: ((cell: SATableViewCell) -> Void)? = nil, onAction: ((sender: SACheckTableViewCell) -> Void)) {
//        self.checkOn  = checkOn
//        self.onAction = onAction
//        super.init(cellIdentifier: cellIdentifier, title: title, customization: customization, onSelection: { () -> Void in  })
//        if self.customization == nil {
//            self.customization = { (cell: SATableViewCell) -> Void in
//                let checkOn = (cell.tableObject as? SACheckTableObject)?.checkOn ?? false
//                cell.accessoryType = checkOn ? .Checkmark : .None
//            }
//        }
//    }
//}
//public class SACheckTableViewCell: SATitleTableViewCell {
//    //@IBOutlet weak var checkView: UIImageView?
//    public override var tableObject: SATableObject! {
//        didSet {
//            titleLabel?.text = (tableObject as! SACheckTableObject).title
//            accessoryType    = (tableObject as! SACheckTableObject).checkOn ? .Checkmark : .None
//        }
//    }
//    public override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        if selected { (tableObject as! SACheckTableObject).onAction(sender: self) }
//    }
//}
//
//// Check Cell
//public class SATextFieldTableObject: SATitleTableObject {
//    public var text: String?
//    public var placeholder: String?
//    public var onAction: ((sender: SATextFieldTableViewCell) -> Void)
//    init(cellIdentifier: String = "TextFieldCell", title: String?, text: String?, placeholder: String?,
//         customization: ((cell: SATableViewCell) -> Void)? = nil, onAction: ((sender: SATextFieldTableViewCell) -> Void)) {
//        self.text = text
//        self.placeholder = placeholder
//        self.onAction = onAction
//        super.init(cellIdentifier: cellIdentifier, title: title, customization: customization, onSelection: { () -> Void in  })
//    }
//}
//public class SATextFieldTableViewCell: SATitleTableViewCell {
//    @IBOutlet weak var textField: UITextField?
//    public override var tableObject: SATableObject! {
//        didSet {
//            titleLabel?.text       = (tableObject as! SATextFieldTableObject).title
//            textField?.text        = (tableObject as! SATextFieldTableObject).text
//            textField?.placeholder = (tableObject as! SATextFieldTableObject).placeholder
//            textField?.addTarget(self, action: #selector(textFieldChanged(_:)), forControlEvents: .EditingChanged)
//        }
//    }
//    public func textFieldChanged(sender: UITextField!) {
//        (tableObject as! SATextFieldTableObject).onAction(sender: self)
//    }
//}