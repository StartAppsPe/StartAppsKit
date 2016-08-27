//
//  StaticLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 12/11/15.
//
//

import Foundation

import UIKit

public class StaticLoadAction: LoadAction<StaticContent> {
    
    public typealias StaticContentResultType    = Result<StaticContent, ErrorType>
    public typealias StaticContentResultClosure = (result: StaticContentResultType) -> Void
    public typealias StaticContentResult        = (completion: StaticContentResultClosure) -> Void
    
    public init(
        staticItems: StaticContentResult,
        delegates:   [LoadActionDelegate] = [],
        dummy:       (() -> ())? = nil)
    {
        super.init(
            load: staticItems,
            delegates: delegates
        )
    }
    
}


public class StaticContent: NSObject, UITableViewDataSource {
    public var sections: [StaticContentSection] = []
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return sections[indexPath.section].items[indexPath.row].dequeueReusableCell(tableView: tableView, indexPath: indexPath)
    }
    
}
public func += (inout left: StaticContent, right: StaticContentSection) {
    left.sections.append(right)
}


public class StaticContentSection {
    public var title: String?
    public var items: [StaticContentItemProtocol] = []
    public init(title: String? = nil) {
        self.title = title
    }
}
public func += (inout left: [StaticContentSection], right: StaticContentSection) {
    left.append(right)
}
public func += (inout left: StaticContentSection, right: StaticContentItemProtocol) {
    left.items.append(right)
}



public protocol StaticContentItemProtocol {
    func dequeueReusableCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> StaticTableViewCell
    func doOnSelection(cell cell: StaticTableViewCell)
    func doOnAction(cell cell: StaticTableViewCell)
}

public class StaticContentItem<C: StaticTableViewCell>: StaticContentItemProtocol {
    public var cellIdentifier: String
    private var customization: ((cell: C) -> Void)?
    private var onSelection:   ((cell: C) -> Void)?
    private var onAction:      ((cell: C) -> Void)?
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
    public func dequeueReusableCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> StaticTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! C
        cell.contentItem = self
        customization?(cell: cell)
        return cell
    }
    public func doOnSelection(cell cell: StaticTableViewCell) {
        onSelection?(cell: self as! C)
    }
    public func doOnAction(cell cell: StaticTableViewCell) {
        onAction?(cell: self as! C)
    }
}

public class StaticTableViewCell: UITableViewCell {
    public class func defaultIdentifier() -> String { return "StaticTableViewCell" }
    public var contentItem: StaticContentItemProtocol!
    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentItem.doOnSelection(cell: self)
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
        contentItem.doOnAction(cell: self)
    }
}
public class SwitchStaticTableViewCell: TextStaticTableViewCell {
    public override class func defaultIdentifier() -> String { return "SwitchStaticTableViewCell" }
    @IBOutlet weak var switchView: UISwitch?
    public override var contentItem: StaticContentItemProtocol! {
        didSet {
            switchView?.setAction(controlEvents: .ValueChanged, action: { (sender) in
                self.contentItem.doOnAction(cell: self)
            })
        }
    }
}

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