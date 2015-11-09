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
    var header:  String?
    var objects: [SATableObject]!
    func append(object: SATableObject) {
        objects.append(object)
    }
    init(header: String? = nil, objects: [SATableObject]? = nil) {
        self.header = header
        self.objects = objects ?? [SATableObject]()
    }
}
public func += (inout left: [SATableObjectsSection], right: SATableObjectsSection?) {
    if let right = right { left.append(right) }
}
public func += (inout left: SATableObjectsSection, right: SATableObject?) {
    if let right = right { left.append(right) }
}



// Default cell
public class SATableObject {
    public var cellIdentifier: String!
    public var onSelection:   (() -> Void)?
    public var customization: ((cell: SATableViewCell) -> Void)?
    init(cellIdentifier: String, customization: ((cell: SATableViewCell) -> Void)? = nil, onSelection: (() -> Void)? = nil) {
        self.cellIdentifier = cellIdentifier
        self.customization  = customization
        self.onSelection    = onSelection
    }
}
public class SATableViewCell: UITableViewCell {
    public var tableObject: SATableObject!
}

// Title cell
public class SATitleTableObject: SATableObject {
    public var image: UIImage?
    public var title: String?
    init(cellIdentifier: String = "TitleCell", title: String?, image: UIImage? = nil,
        customization: ((cell: SATableViewCell) -> Void)? = nil, onSelection: (() -> Void)? = nil) {
            self.image = image
            self.title = title
            super.init(cellIdentifier: cellIdentifier, customization: customization, onSelection: onSelection)
    }
}
public class SATitleTableViewCell: SATableViewCell {
    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet public weak var customImageView: UIImageView?
    public override var tableObject: SATableObject! {
        didSet {
            titleLabel?.text = (tableObject as! SATitleTableObject).title
            customImageView?.image = (tableObject as! SATitleTableObject).image
            if customImageView == nil {
                imageView?.image = (tableObject as! SATitleTableObject).image
            }
        }
    }
}

// Text Cell
public class SATextTableObject: SATitleTableObject {
    public var text: String?
    init(cellIdentifier: String = "TextCell", title: String?, text: String? = nil, image: UIImage? = nil,
        customization: ((cell: SATableViewCell) -> Void)? = nil, onSelection: (() -> Void)? = nil) {
            self.text = text
            super.init(cellIdentifier: cellIdentifier, title: title, image: image, customization: customization, onSelection: onSelection)
    }
}
public class SATextTableViewCell: SATitleTableViewCell {
    @IBOutlet public weak var contentLabel: UILabel?
    public override var tableObject: SATableObject! {
        didSet {
            titleLabel?.text   = (tableObject as! SATextTableObject).title
            contentLabel?.text = (tableObject as! SATextTableObject).text
            customImageView?.image = (tableObject as! SATitleTableObject).image
            if customImageView == nil {
                imageView?.image = (tableObject as! SATitleTableObject).image
            }
        }
    }
}

// Button Cell
public class SAButtonTableObject: SATitleTableObject {
    public var color: UIColor
    public var textColor: UIColor
    public var onAction: ((sender: SAButtonTableViewCell) -> Void)
    init(cellIdentifier: String = "ButtonCell", title: String, image: UIImage? = nil, color: UIColor? = nil, textColor: UIColor? = nil,
        customization: ((cell: SATableViewCell) -> Void)? = nil, onAction: ((sender: SAButtonTableViewCell) -> Void)) {
            self.color     = color     ?? UIColor.whiteColor()
            self.textColor = textColor ?? UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            self.onAction  = onAction
            super.init(cellIdentifier: cellIdentifier, title: title, image: image, customization: customization, onSelection: { () -> Void in })
            if self.customization == nil { self.customization = { (cell: SATableViewCell) -> Void in cell.accessoryType = .None } }
    }
}
public class SAButtonTableViewCell: SATitleTableViewCell {
    public override var tableObject: SATableObject! {
        didSet {
            titleLabel?.text      = (tableObject as! SAButtonTableObject).title
            titleLabel?.textColor = (tableObject as! SAButtonTableObject).textColor
            backgroundColor       = (tableObject as! SAButtonTableObject).color
            customImageView?.image = (tableObject as! SATitleTableObject).image
            if customImageView == nil {
                imageView?.image = (tableObject as! SATitleTableObject).image
            }
        }
    }
    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected { (tableObject as! SAButtonTableObject).onAction(sender: self) }
    }
}

// Switch Cell
public class SASwitchTableObject: SATitleTableObject {
    public var switchOn: Bool
    public var onAction: ((sender: SASwitchTableViewCell) -> Void)
    init(cellIdentifier: String = "SwitchCell", title: String?, image: UIImage? = nil, switchOn: Bool,
        customization: ((cell: SATableViewCell) -> Void)? = nil, onAction: ((sender: SASwitchTableViewCell) -> Void), onSelection: (() -> Void)? = nil) {
            self.switchOn = switchOn
            self.onAction = onAction
            super.init(cellIdentifier: cellIdentifier, title: title, image: image, customization: customization, onSelection: onSelection)
    }
}
public class SASwitchTableViewCell: SATitleTableViewCell {
    @IBOutlet public weak var switchView: UISwitch?
    public override var tableObject: SATableObject! {
        didSet {
            titleLabel?.text = (tableObject as! SASwitchTableObject).title
            switchView?.on   = (tableObject as! SASwitchTableObject).switchOn
            switchView?.addTarget(self, action: "switchAction:", forControlEvents: .ValueChanged)
            customImageView?.image = (tableObject as! SASwitchTableObject).image
            if customImageView == nil {
                imageView?.image = (tableObject as! SASwitchTableObject).image
            }
        }
    }
    public func switchAction(sender: UISwitch!) {
        (tableObject as! SASwitchTableObject).onAction(sender: self)
    }
}

// Slider Cell
public class SASliderTableObject: SATitleTableObject {
    public var sliderValue: Float
    public var valueString: String?
    public var onAction: ((sender: SASliderTableViewCell) -> Void)
    init(cellIdentifier: String = "SliderCell", title: String?, image: UIImage? = nil, sliderValue: Float, valueString: String? = nil,
        customization: ((cell: SATableViewCell) -> Void)? = nil, onAction: ((sender: SASliderTableViewCell) -> Void), onSelection: (() -> Void)? = nil) {
            self.sliderValue = sliderValue
            self.valueString = valueString
            self.onAction = onAction
            super.init(cellIdentifier: cellIdentifier, title: title, image: image, customization: customization, onSelection: onSelection)
    }
}
public class SASliderTableViewCell: SATitleTableViewCell {
    @IBOutlet public weak var sliderView: UISlider?
    @IBOutlet public weak var valueLabel: UILabel?
    public override var tableObject: SATableObject! {
        didSet {
            titleLabel?.text  = (tableObject as! SASliderTableObject).title
            valueLabel?.text  = (tableObject as! SASliderTableObject).valueString
            sliderView?.value = (tableObject as! SASliderTableObject).sliderValue
            sliderView?.addTarget(self, action: "sliderAction:", forControlEvents: .ValueChanged)
            customImageView?.image = (tableObject as! SASliderTableObject).image
            if customImageView == nil {
                imageView?.image = (tableObject as! SASliderTableObject).image
            }
        }
    }
    public func sliderAction(sender: UISlider!) {
        (tableObject as! SASliderTableObject).onAction(sender: self)
    }
}

// Check Cell
public class SACheckTableObject: SATitleTableObject {
    public var checkOn:  Bool
    public var onAction: ((sender: SACheckTableViewCell) -> Void)
    init(cellIdentifier: String = "CheckCell", title: String?, image: UIImage? = nil, checkOn: Bool,
        customization: ((cell: SATableViewCell) -> Void)? = nil, onAction: ((sender: SACheckTableViewCell) -> Void), onSelection: (() -> Void)? = { }) {
            self.checkOn  = checkOn
            self.onAction = onAction
            super.init(cellIdentifier: cellIdentifier, title: title, image: image, customization: customization, onSelection: onSelection)
            if self.customization == nil {
                self.customization = { (cell: SATableViewCell) -> Void in
                    let checkOn = (cell.tableObject as? SACheckTableObject)?.checkOn ?? false
                    cell.accessoryType = checkOn ? .Checkmark : .None
                }
            }
    }
}
public class SACheckTableViewCell: SATitleTableViewCell {
    //@IBOutlet weak var checkView: UIImageView?
    public override var tableObject: SATableObject! {
        didSet {
            titleLabel?.text = (tableObject as! SACheckTableObject).title
            accessoryType    = (tableObject as! SACheckTableObject).checkOn ? .Checkmark : .None
            customImageView?.image = (tableObject as! SATitleTableObject).image
            if customImageView == nil {
                imageView?.image = (tableObject as! SATitleTableObject).image
            }
        }
    }
    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected { (tableObject as! SACheckTableObject).onAction(sender: self) }
    }
}

// TextField Cell
public class SATextFieldTableObject: SATitleTableObject {
    public var text: String?
    public var placeholder: String?
    public var onAction: ((sender: SATextFieldTableViewCell) -> Void)
    init(cellIdentifier: String = "TextFieldCell", title: String?, text: String?, image: UIImage? = nil, placeholder: String?,
        customization: ((cell: SATableViewCell) -> Void)? = nil, onAction: ((sender: SATextFieldTableViewCell) -> Void), onSelection: (() -> Void)? = nil) {
            self.text = text
            self.placeholder = placeholder
            self.onAction = onAction
            super.init(cellIdentifier: cellIdentifier, title: title, image: image, customization: customization, onSelection: onSelection)
    }
}
public class SATextFieldTableViewCell: SATitleTableViewCell {
    @IBOutlet weak var textField: UITextField?
    public override var tableObject: SATableObject! {
        didSet {
            titleLabel?.text       = (tableObject as! SATextFieldTableObject).title
            textField?.text        = (tableObject as! SATextFieldTableObject).text
            textField?.placeholder = (tableObject as! SATextFieldTableObject).placeholder
            textField?.addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
            customImageView?.image = (tableObject as! SATitleTableObject).image
            if customImageView == nil {
                imageView?.image = (tableObject as! SATitleTableObject).image
            }
        }
    }
    public func textFieldChanged(sender: UITextField!) {
        (tableObject as! SATextFieldTableObject).onAction(sender: self)
    }
}

// TextView Cell
public class SATextViewTableObject: SATitleTableObject {
    public var text: String?
    public var onAction: ((sender: SATextViewTableViewCell) -> Void)
    init(cellIdentifier: String = "TextViewCell", title: String?, text: String?, image: UIImage? = nil,
        customization: ((cell: SATableViewCell) -> Void)? = nil, onAction: ((sender: SATextViewTableViewCell) -> Void), onSelection: (() -> Void)? = nil) {
            self.text = text
            self.onAction = onAction
            super.init(cellIdentifier: cellIdentifier, title: title, image: image, customization: customization, onSelection: onSelection)
    }
}
public class SATextViewTableViewCell: SATitleTableViewCell, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView?
    public override var tableObject: SATableObject! {
        didSet {
            titleLabel?.text       = (tableObject as! SATextViewTableObject).title
            textView?.text         = (tableObject as! SATextViewTableObject).text
            textView?.delegate     = self
            customImageView?.image = (tableObject as! SATextViewTableObject).image
            if customImageView == nil {
                imageView?.image = (tableObject as! SATextViewTableObject).image
            }
        }
    }
    public func textViewDidEndEditing(textView: UITextView) {
        (tableObject as! SATextViewTableObject).onAction(sender: self)
    }
}