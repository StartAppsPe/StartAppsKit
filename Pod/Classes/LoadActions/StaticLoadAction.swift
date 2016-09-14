//
//  StaticLoadAction.swift
//  Pods
//
//  Created by Gabriel Lanata on 12/11/15.
//
//

import Foundation

import UIKit

open class StaticLoadAction: LoadAction<StaticContent> {
    
    public typealias StaticContentResult = () throws -> StaticContent
    
    open var staticContentClosure: StaticContentResult
    
    open let dataSource = StaticDataSource()
    
    fileprivate func loadInner(completion: LoadResultClosure) {
        do {
            let staticContent = try staticContentClosure()
            completion(.success(staticContent))
        } catch(let error) {
            completion(.failure(error))
        }
    }
    
    public init(
        staticContent: @escaping StaticContentResult,
        dummy:       (() -> ())? = nil)
    {
        self.staticContentClosure = staticContent
        super.init(
            load: { _ in }
        )
        self.loadClosure = { (completion) -> Void in
            self.loadInner(completion: completion)
        }
        dataSource.loadAction = self
    }
    
}

open class StaticDataSource: NSObject, UITableViewDataSource {
    
    weak var loadAction: StaticLoadAction!
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return loadAction.value?.sections.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return loadAction.value?.sections[section].title
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadAction.value?.sections[section].items.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return loadAction.value!.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row].dequeueReusableCell(tableView: tableView, indexPath: indexPath)
    }
    
}

open class StaticContent {
    open var sections: [StaticContentSection] = []
    public init() {
    }
}
public func += (left: inout StaticContent, right: StaticContentSection) {
    left.sections.append(right)
}


open class StaticContentSection {
    open var title: String?
    open var items: [StaticContentItemProtocol] = []
    public init(title: String? = nil) {
        self.title = title
    }
}
public func += (left: inout [StaticContentSection], right: StaticContentSection) {
    left.append(right)
}
public func += (left: inout StaticContentSection, right: StaticContentItemProtocol) {
    left.items.append(right)
}



public protocol StaticContentItemProtocol {
    func dequeueReusableCell(tableView: UITableView, indexPath: IndexPath) -> StaticTableViewCell
    func doOnSelection(cell: StaticTableViewCell)
    func doOnAction(cell: StaticTableViewCell)
}

open class StaticContentItem<C: StaticTableViewCell>: StaticContentItemProtocol {
    open var cellIdentifier: String
    fileprivate var customization: ((_ cell: C) -> Void)?
    fileprivate var onSelection:   ((_ cell: C) -> Void)?
    fileprivate var onAction:      ((_ cell: C) -> Void)?
    public init(cellIdentifier: String) {
        self.cellIdentifier = cellIdentifier
    }
    open func setCustomization(_ customization: ((_ cell: C) -> Void)?) {
        self.customization = customization
    }
    open func setOnSelection(_ onSelection: ((_ cell: C) -> Void)?) {
        self.onSelection = onSelection
    }
    open func setOnAction(_ onAction: ((_ cell: C) -> Void)?) {
        self.onAction = onAction
    }
    open func dequeueReusableCell(tableView: UITableView, indexPath: IndexPath) -> StaticTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! C
        cell.contentItem = self
        customization?(cell)
        return cell
    }
    open func doOnSelection(cell: StaticTableViewCell) {
        onSelection?(cell as! C)
    }
    open func doOnAction(cell: StaticTableViewCell) {
        onAction?(cell as! C)
    }
}

open class StaticTableViewCell: UITableViewCell {
    open class func defaultIdentifier() -> String { return "StaticTableViewCell" }
    open var contentItem: StaticContentItemProtocol!
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected { contentItem.doOnSelection(cell: self) }
    }
}
open class TitleStaticTableViewCell: StaticTableViewCell {
    open override class func defaultIdentifier() -> String { return "TitleStaticTableViewCell" }
    @IBOutlet open weak var titleLabel: UILabel?
}
open class TextStaticTableViewCell: TitleStaticTableViewCell {
    open override class func defaultIdentifier() -> String { return "TextStaticTableViewCell" }
    @IBOutlet open weak var contentLabel: UILabel?
}
open class PictureStaticTableViewCell: TextStaticTableViewCell {
    open override class func defaultIdentifier() -> String { return "PictureStaticTableViewCell" }
    @IBOutlet open weak var pictureView: UIImageView?
}

open class ButtonStaticTableViewCell: PictureStaticTableViewCell {
    open override class func defaultIdentifier() -> String { return "ButtonStaticTableViewCell" }
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected { contentItem.doOnAction(cell: self) }
    }
}
open class SwitchStaticTableViewCell: TextStaticTableViewCell {
    open override class func defaultIdentifier() -> String { return "SwitchStaticTableViewCell" }
    @IBOutlet open weak var switchView: UISwitch?
    open override var contentItem: StaticContentItemProtocol! {
        didSet {
            switchView?.setAction(controlEvents: .valueChanged, action: { (sender) in
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
