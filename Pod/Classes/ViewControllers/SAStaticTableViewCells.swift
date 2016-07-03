//
//  SAStaticTableViewCells.swift
//  ULima
//
//  Created by Gabriel Lanata on 5/28/15.
//  Copyright (c) 2015 Universidad de Lima. All rights reserved.
//

import UIKit


// Section Management
public class SATableObjectsSection {
    public var header:  String?
    public var objects: [SATableObjectType]!
    public func append(object: SATableObjectType) {
        objects.append(object)
    }
    public init(header: String? = nil, objects: [SATableObjectType]? = nil) {
        self.header = header
        self.objects = objects ?? [SATableObject]()
    }
    public func dequeueGenericCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> SATableViewCell {
        return objects[indexPath.row].dequeueGenericCell(tableView: tableView, indexPath: indexPath)
    }
    public func didSelect(tableView tableView: UITableView, indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = dequeueGenericCell(tableView: tableView, indexPath: indexPath)
        objects[indexPath.row].didSelect(cell: cell)
    }
    public func didAction(tableView tableView: UITableView, indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = dequeueGenericCell(tableView: tableView, indexPath: indexPath)
        objects[indexPath.row].didAction(cell: cell)
    }
}
public func += (inout left: [SATableObjectsSection], right: SATableObjectsSection?) {
    if let right = right { left.append(right) }
}
public func += (inout left: SATableObjectsSection, right: SATableObjectType?) {
    if let right = right { left.append(right) }
}

// Table Object
public class SATableObject<T: SATableViewCell>: SATableObjectType {
    public var customization: ((cell: T) -> Void)?
    public var onSelection:   ((cell: T) -> Void)?
    public var onAction:      ((cell: T) -> Void)?
    public init(customization: ((cell: T) -> Void)? = nil, onSelection: ((cell: T) -> Void)? = nil) {
        self.customization = customization
        self.onSelection   = onSelection
    }
    public func dequeueCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> T {
        let cell = tableView.dequeueReusableCellWithIdentifier(T.cellIdentifier(), forIndexPath: indexPath) as! T
        cell.tableObject = self
        customization?(cell: cell)
        return cell
    }
    public func dequeueGenericCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> SATableViewCell {
        return dequeueCell(tableView: tableView, indexPath: indexPath)
    }
    public func didSelect(cell cell: SATableViewCell) {
        onSelection?(cell: cell as! T)
    }
    public func didAction(cell cell: SATableViewCell) {
        onAction?(cell: cell as! T)
    }
}
extension SATableObject where T: SATableViewCellActionable {
    public convenience init(customization: ((cell: T) -> Void)? = nil, onSelection: ((cell: T) -> Void)? = nil, onAction: ((cell: T) -> Void)?) {
        self.init(customization: customization, onSelection: onSelection)
        self.onAction = onAction
    }
}

public protocol SATableObjectType {
    func dequeueGenericCell(tableView tableView: UITableView, indexPath: NSIndexPath) -> SATableViewCell
    func didSelect(cell cell: SATableViewCell)
    func didAction(cell cell: SATableViewCell)
}

public protocol SATableViewCellActionable {
    func didAction(sender: AnyObject!)
}

// Default cell
public class SATableViewCell: UITableViewCell {
    public var tableObject: SATableObjectType!
    public class func cellIdentifier() -> String { return "SATableViewCell" }
    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        tableObject?.didSelect(cell: self)
    }
}

// Title cell
public class SATitleTableViewCell: SATableViewCell {
    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet public weak var customImageView: UIImageView?
    public override class func cellIdentifier() -> String { return "SATitleTableViewCell" }
}

// Text Cell
public class SATextTableViewCell: SATitleTableViewCell {
    @IBOutlet public weak var contentLabel: UILabel?
    public override class func cellIdentifier() -> String { return "SATextTableViewCell" }
}

// Button Cell
public class SAButtonTableViewCell: SATitleTableViewCell {
    public override class func cellIdentifier() -> String { return "SAButtonTableViewCell" }
}

// Switch Cell
public class SASwitchTableViewCell: SATitleTableViewCell, SATableViewCellActionable {
    @IBOutlet public weak var switchView: UISwitch? {
        didSet { switchView?.addTarget(self, action: #selector(SASwitchTableViewCell.didAction(_:)), forControlEvents: .ValueChanged) }
    }
    public override class func cellIdentifier() -> String { return "SASwitchTableViewCell" }
    public func didAction(sender: AnyObject!) { tableObject.didAction(cell: self) }
}

// Slider Cell
public class SASliderTableViewCell: SATitleTableViewCell, SATableViewCellActionable {
    @IBOutlet public weak var sliderView: UISlider? {
        didSet { sliderView?.addTarget(self, action: #selector(SASwitchTableViewCell.didAction(_:)), forControlEvents: .ValueChanged) }
    }
    @IBOutlet public weak var valueLabel: UILabel?
    public override class func cellIdentifier() -> String { return "SASliderTableViewCell" }
    public func didAction(sender: AnyObject!) { tableObject.didAction(cell: self) }
}

// TextField Cell
public class SASegmentedTableViewCell: SATitleTableViewCell, SATableViewCellActionable {
    @IBOutlet public weak var segmentedControl: UISegmentedControl? {
        didSet { segmentedControl?.addTarget(self, action: #selector(SASwitchTableViewCell.didAction(_:)), forControlEvents: .ValueChanged) }
    }
    public override class func cellIdentifier() -> String { return "SASegmentedTableViewCell" }
    public func didAction(sender: AnyObject!) { tableObject.didAction(cell: self) }
}

// TextField Cell
public class SATextFieldTableViewCell: SATitleTableViewCell, SATableViewCellActionable {
    @IBOutlet public weak var textField: UITextField? {
        didSet { textField?.addTarget(self, action: #selector(SASwitchTableViewCell.didAction(_:)), forControlEvents: .EditingChanged) }
    }
    public override class func cellIdentifier() -> String { return "SATextFieldTableViewCell" }
    public func didAction(sender: AnyObject!) { tableObject.didAction(cell: self) }
}

// TextView Cell
public class SATextViewTableViewCell: SATitleTableViewCell, UITextViewDelegate {
    @IBOutlet public weak var textView: UITextView? {
        didSet { textView?.delegate = self }
    }
    public override class func cellIdentifier() -> String { return "SATextViewTableViewCell" }
    public func textViewDidEndEditing(textView: UITextView) { didAction(textView) }
    public func didAction(sender: AnyObject!) { tableObject.didAction(cell: self) }
}
