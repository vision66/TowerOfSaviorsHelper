//
//  NSLayoutConstraintHelper.swift
//  NSLayoutConstraintHelper
//
//  Created by weizhen on 16/8/1.
//

import UIKit

extension UIColor {
    
    convenience init(hexInteger: Int, alpha: CGFloat = 1.0) {
        self.init(red: ((hexInteger >> 16) & 0xFF) / 255.0, green:((hexInteger >> 8) & 0xFF) / 255.0, blue:((hexInteger) & 0xFF) / 255.0, alpha:alpha)
    }
}

extension UIFont {
    
    static func monsopacedFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica Neue", size: fontSize)!
    }
}

extension UIImage {
    
    /// 从Assets目录加载图片
    static func assetNamed(_ name: String) -> UIImage? {
        return UIImage(named: "Assets/" + name)
    }
    
    /// 从Assets目录加载图片, 并进行九宫格方式拉伸
    static func assetNamed(_ name: String, resizableImageWithCapInsets capInsets: UIEdgeInsets) -> UIImage? {
        return UIImage(named: "Assets/" + name)?.resizableImage(withCapInsets: capInsets)
    }
    
    /// 从Assets目录加载图片, 并进行九宫格方式拉伸
    static func assetNamed(_ name: String, resizableImageWithCapInsets capInsets: UIEdgeInsets, resizingMode mode: UIImageResizingMode) -> UIImage? {
        return UIImage(named: "Assets/" + name)?.resizableImage(withCapInsets: capInsets, resizingMode: mode)
    }
    
    /// 以拉伸的方式, 直至将区域填满, 形成新的图片
    func scaleToFillSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // 长宽以相同的比例拉伸, 直至将区域填满, 形成新的图片
    func scaleAspectFillSize(_ size: CGSize) -> UIImage {
        
        let sourceSize = self.size
        let targetSize = size
        
        var thumbnailX = 0 as CGFloat
        var thumbnailY = 0 as CGFloat
        var thumbnailW = targetSize.width
        var thumbnailH = targetSize.height

        if __CGSizeEqualToSize(sourceSize, targetSize) == false {
            
            // thumbnail factor
            let factorW = targetSize.width / sourceSize.width
            let factorH = targetSize.height / sourceSize.height
            let factor = (factorW > factorH) ? factorW : factorH
            
            // thumbnail size
            thumbnailW = sourceSize.width * factor
            thumbnailH = sourceSize.height * factor
            
            // center the image
            if factorW > factorH {
                thumbnailY = (targetSize.height - thumbnailH) * 0.5
            } else if factorW < factorH {
                thumbnailX = (targetSize.width - thumbnailW) * 0.5
            }
        }
        
        let thumbnailRect = CGRectMake(thumbnailX, thumbnailY, thumbnailW, thumbnailH)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, self.scale)
        self.draw(in: thumbnailRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 压缩图片到适合大小, 然后将图片数据(JPG格式)输出
    var jpgData : Data {
        
        var curCompression = 0.9 as CGFloat
        let maxCompression = 0.1 as CGFloat
        let maxFileSize = 100 * 1024
        
        let sourceImage = self
        
        var imageData = UIImageJPEGRepresentation(sourceImage, curCompression)!
        
        while imageData.count > maxFileSize && curCompression > maxCompression {
            curCompression -= 0.1
            imageData = UIImageJPEGRepresentation(sourceImage, curCompression)!
        }
        
        return imageData
    }
    
    /// 输出PNG格式的图片数据
    var pngData : Data {
        return UIImagePNGRepresentation(self)!
    }
    
    /// 生成纯色组成的图片
    func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 给当前图片混合颜色
    func imageWithBlendColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        // CGContextTranslateCTM(context, 0, self.size.height);
        // CGContextScaleCTM(context, 1.0, -1.0);
        context.setBlendMode(.normal)
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 生成圆角图片
    func imageWithCorner(_ cornerRadius: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        path.addClip()
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 生成圆形图片
    var circleImage : UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        context.addEllipse(in: rect)
        context.clip()
        context.draw(self.cgImage!, in: rect)
        //CGContextSetLineWidth(context, 4);
        //CGContextSetLineColorWithHex(context, 0x00FF00, 1.0);
        //CGContextStrokePath(context);
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 生成灰色图片
    var grayImage : UIImage? {
        
        let w = self.size.width
        let h = self.size.height
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        // CGBitmapContextCreate, kCGBitmapByteOrderDefault
        guard let context = CGContext(data: nil, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0) else {
            return nil
        }
        
        context.draw(self.cgImage!, in: CGRectMake(0, 0, w, h))
        
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        let newImage = UIImage(cgImage: cgImage)
        
        return newImage
    }
    
    /// 生成RGBA格式的Data
    var rgbaData : Data {
        
        guard let imageRef = self.cgImage else {
            fatalError("If the UIImage object was initialized using a CIImage object, the value of the property is NULL.")
        }
        
        let bitsPerPixel = 32
        let bitsPerComponent = 8
        let bytesPerPixel = bitsPerPixel / bitsPerComponent
        
        let width = imageRef.width
        let height = imageRef.height
        
        let bytesPerRow = width * bytesPerPixel
        let bytesOfAll = bytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            fatalError("Create context failed!")
        }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        context.draw(imageRef, in: rect)
        
        // Get a pointer to the data
        let data = Data(bytes: context.data!, count: bytesOfAll)
        
        return data
    }
}

extension UIView {
    
    /// 取得当前快照(UIImage类型)
    var snapshot : UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 取得与自己最近的视图控制器
    var viewController : UIViewController? {
        
        var responder : UIResponder? = self
        
        repeat {
        
            responder = responder?.next
            
            if let viewController = responder as? UIViewController {
                return viewController
            }
            
        } while responder != nil
        
        return nil
    }
    
    var left : CGFloat {
        set { self.frame = CGRectMake(newValue, frame.origin.y, frame.size.width, frame.size.height) }
        get { return frame.origin.x }
    }
    
    var right : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, newValue - frame.origin.x, frame.size.height) }
        get { return frame.origin.x + frame.size.width }
    }
    
    var top : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, newValue, frame.size.width, frame.size.height) }
        get { return frame.origin.y }
    }
    
    var bottom : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, newValue - frame.origin.y) }
        get { return frame.origin.y + frame.size.height }
    }
    
    var width : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, newValue, frame.size.height) }
        get { return frame.size.width }
    }
    
    var height : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, newValue) }
        get { return frame.size.height }
    }
    
    var topLeft : CGPoint {
        set { self.frame = CGRectMake(newValue.x, newValue.y, frame.size.width, frame.size.height) }
        get { return frame.origin }
    }
    
    var rightBottom : CGPoint {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, newValue.x - frame.origin.x, newValue.y - frame.origin.y) }
        get { return CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height) }
    }
    
    var size : CGSize {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, newValue.width, newValue.height) }
        get { return frame.size }
    }
    
    var asLabel : UILabel? {
        return self as? UILabel
    }
}

extension UIScrollView {
    
    var contentOffsetX: CGFloat {
        set { self.contentOffset = CGPointMake(newValue, self.contentOffset.y) }
        get { return self.contentOffset.x }
    }
    
    var contentOffsetY: CGFloat {
        set { self.contentOffset = CGPointMake(self.contentOffset.x, newValue) }
        get { return self.contentOffset.y }
    }
}

extension UIButton {
    
    /// 设置普通文字
    var nnTitle : String? {
        set { self.setTitle(newValue, for: .normal) }
        get { return self.title(for: .normal) }
    }
    
    /// 设置高亮文字
    var nhTitle : String? {
        set { self.setTitle(newValue, for: .highlighted) }
        get { return self.title(for: .highlighted) }
    }
    
    /// 设置禁用文字
    var ndTitle : String? {
        set { self.setTitle(newValue, for: .disabled) }
        get { return self.title(for: .disabled) }
    }
    
    /// 设置选中时的普通文字
    var snTitle : String? {
        set { self.setTitle(newValue, for: UIControlState.selected.union(.normal)) }
        get { return self.title(for: UIControlState.selected.union(.normal)) }
    }
    
    /// 设置选中时的高亮文字
    var shTitle : String? {
        set { self.setTitle(newValue, for: UIControlState.selected.union(.highlighted)) }
        get { return self.title(for: UIControlState.selected.union(.highlighted)) }
    }
    
    /// 设置选中时的禁用文字
    var sdTitle : String? {
        set { self.setTitle(newValue, for: UIControlState.selected.union(.disabled)) }
        get { return self.title(for: UIControlState.selected.union(.disabled)) }
    }
    
    /// 设置普通文字颜色
    var nnTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: .normal) }
        get { return self.titleColor(for: .normal) }
    }
    
    /// 设置高亮文字颜色
    var nhTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: .highlighted) }
        get { return self.titleColor(for: .highlighted) }
    }
    
    /// 设置禁用文字颜色
    var ndTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: .disabled) }
        get { return self.titleColor(for: .disabled) }
    }
    
    /// 设置选中时的普通文字颜色
    var snTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: UIControlState.selected.union(.normal)) }
        get { return self.titleColor(for: UIControlState.selected.union(.normal)) }
    }
    
    /// 设置选中时的高亮文字颜色
    var shTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: UIControlState.selected.union(.highlighted)) }
        get { return self.titleColor(for: UIControlState.selected.union(.highlighted)) }
    }
    
    /// 设置选中时的禁用文字
    var sdTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: UIControlState.selected.union(.disabled)) }
        get { return self.titleColor(for: UIControlState.selected.union(.disabled)) }
    }
    
    /// 设置普通图片
    var nnImage : UIImage? {
        set { self.setImage(newValue, for: .normal) }
        get { return self.image(for: .normal) }
    }
    
    /// 设置高亮图片
    var nhImage : UIImage? {
        set { self.setImage(newValue, for: .highlighted) }
        get { return self.image(for: .highlighted) }
    }
    
    /// 设置禁用图片
    var ndImage : UIImage? {
        set { self.setImage(newValue, for: .disabled) }
        get { return self.image(for: .disabled) }
    }
    
    /// 设置选中时的普通图片
    var snImage : UIImage? {
        set { self.setImage(newValue, for: UIControlState.selected.union(.normal)) }
        get { return self.image(for: UIControlState.selected.union(.normal)) }
    }
    
    /// 设置选中时的高亮图片
    var shImage : UIImage? {
        set { self.setImage(newValue, for: UIControlState.selected.union(.highlighted)) }
        get { return self.image(for: UIControlState.selected.union(.highlighted)) }
    }
    
    /// 设置选中时的禁用图片
    var sdImage : UIImage? {
        set { self.setImage(newValue, for: UIControlState.selected.union(.disabled)) }
        get { return self.image(for: UIControlState.selected.union(.disabled)) }
    }
    
    /// 设置普通背景
    var nnBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: .normal) }
        get { return self.backgroundImage(for: .normal) }
    }
    
    /// 设置高亮背景
    var nhBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: .highlighted) }
        get { return self.backgroundImage(for: .highlighted) }
    }
    
    /// 设置禁用背景
    var ndBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: .disabled) }
        get { return self.backgroundImage(for: .disabled) }
    }
    
    /// 设置选中时的普通背景
    var snBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: UIControlState.selected.union(.normal)) }
        get { return self.backgroundImage(for: UIControlState.selected.union(.normal)) }
    }
    
    /// 设置选中时的高亮背景
    var shBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: UIControlState.selected.union(.highlighted)) }
        get { return self.backgroundImage(for: UIControlState.selected.union(.highlighted)) }
    }
    
    /// 设置选中时的禁用背景
    var sdBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: UIControlState.selected.union(.disabled)) }
        get { return self.backgroundImage(for: UIControlState.selected.union(.disabled)) }
    }
    
    /// 使用其他按钮的风格进行配置
    var sameto : UIButton {
        set {
            self.layer.borderWidth = newValue.layer.borderWidth
            self.layer.borderColor = newValue.layer.borderColor
            self.layer.cornerRadius = newValue.layer.cornerRadius
            self.layer.masksToBounds = newValue.layer.masksToBounds
            self.nnTitleColor = newValue.nnTitleColor
            self.titleLabel?.font = newValue.titleLabel?.font
            self.titleEdgeInsets = newValue.titleEdgeInsets
            self.imageEdgeInsets = newValue.imageEdgeInsets
            self.backgroundColor = newValue.backgroundColor
            self.contentVerticalAlignment = newValue.contentVerticalAlignment
            self.contentHorizontalAlignment = newValue.contentHorizontalAlignment
        }
        get {
            return self
        }
    }
}

extension UITableView {
    
    var backgroundLabel: UILabel? {
        set { self.backgroundView = newValue }
        get { return self.backgroundView as? UILabel }
    }

    var messageWhenNoItem: NSAttributedString? {
        
        set {
            if let label = self.backgroundLabel {
                label.attributedText = newValue
            } else {
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 16)
                label.textAlignment = .center
                label.textColor = UIColor.darkGray
                label.isHidden = true
                label.numberOfLines = 0
                label.attributedText = newValue
                self.backgroundView = label
            }
        }
        
        get {
            return self.backgroundLabel?.attributedText
        }
    }
}

extension UITableViewCell {
    
    static var defaultIdentifier : String {
        return NSStringFromClass(self)
    }
}

/// UITableViewCellStyle.Value1
class UITableViewCellValue1 : UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
    }
}

/// UITableViewCellStyle.Value2
class UITableViewCellValue2 : UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.value2, reuseIdentifier: reuseIdentifier)
    }
}

/// UITableViewCellStyle.Subtitle
class UITableViewCellSubtitle : UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    }
}

extension UICollectionViewCell {
    
    static var defaultIdentifier : String {
        return NSStringFromClass(self)
    }
}

extension UITableViewHeaderFooterView {
    
    static var defaultIdentifier : String {
        return NSStringFromClass(self)
    }
}

extension UISearchBar {
    
    /// 禁用文字的自动纠错功能
    var autoSpell : Bool {
        
        set {
            self.autocapitalizationType = .none
            self.autocorrectionType = .no
            self.spellCheckingType = .no
        }
        
        get {
            return self.autocapitalizationType == .none && self.autocorrectionType == .no && self.spellCheckingType == .no
        }
    }
}

extension UITextField {
    
    /// 禁用文字的自动纠错功能
    var autoSpell : Bool {
        
        set {
            self.autocapitalizationType = .none
            self.autocorrectionType = .no
            self.spellCheckingType = .no
        }
        
        get {
            return self.autocapitalizationType == .none && self.autocorrectionType == .no && self.spellCheckingType == .no
        }
    }
}

extension UITextView {
    
    /// 禁用文字的自动纠错功能
    var autoSpell : Bool {
        
        set {
            self.autocapitalizationType = .none
            self.autocorrectionType = .no
            self.spellCheckingType = .no
        }
        
        get {
            return self.autocapitalizationType == .none && self.autocorrectionType == .no && self.spellCheckingType == .no
        }
    }
}

enum UINavigationBarStyle: Int {
    case dark = 0
    case light
    case translucent
}

extension UINavigationBar {
    
    var navigationBarStyle : UINavigationBarStyle {
        
        set {
            if newValue == .light {
                self.setBackgroundImage(UIImage(named: "Resource.bundle/navi_background_light"), for: .default)
            } else if newValue == .dark {
                if UIDevice.current.iPhoneX {
                    self.setBackgroundImage(UIImage(named: "Resource.bundle/navi_background_dark_ipx"), for: .default)
                } else {
                    self.setBackgroundImage(UIImage(named: "Resource.bundle/navi_background_dark"), for: .default)
                }
            } else {
                self.setBackgroundImage(UIImage(), for: .default)
            }
        }
        
        get {
            return .light
        }
    }
}

extension UINavigationController {
    
    func popToLastViewController(animated: Bool) {
        _ = self.popViewController(animated: animated)
    }
}

enum UIBarButtonCustomItem: Int {
    case back
    case done
    case cancel
    case edit
    case save
    case append
    case handInput
    case scanInput
    case compose
    case reply
    case action
    case organize
    case bookmarks
    case search
    case refresh
    case stop
    case camera
    case trash
    case play
    case pause
    case rewind
    case fastForward
    case undo
    case redo
    case date
    case download
    case option
    case message
    case none
}

extension UIBarButtonItem {
    
    /// 使用按钮文字生成UIBarButtonItem
    static func barButtonItem(title: String, target: Any?, action: Selector) -> UIBarButtonItem {
        let button = UIButton(frame: CGRectMake(0, 0, 44, 44))
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.nnTitle = title
        button.nnTitleColor = UIColor.white
        button.nhTitleColor = UIColor.brown
        button.addTarget(target, action: action, for: .touchUpInside)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
    
    /// 使用图片名称生成UIBarButtonItem
    static func barButtonItem(image: String, target: Any?, action: Selector) -> UIBarButtonItem {
        let button = UIButton(frame: CGRectMake(0, 0, 44, 44))
        button.nnImage = UIImage.assetNamed(image)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
    
    /// 使用内置的图标
    static func barButtonCustomItem(_ customItem: UIBarButtonCustomItem, target: Any?, action: Selector) -> UIBarButtonItem {
        
        let imageName: String
        if      customItem == .back       {imageName = "navi_back"}
        else if customItem == .save       {imageName = "navi_save"}
        else if customItem == .date       {imageName = "navi_date"}
        else if customItem == .trash      {imageName = "navi_trash"}
        else if customItem == .handInput  {imageName = "navi_input_hand"}
        else if customItem == .scanInput  {imageName = "navi_input_scan"}
        else if customItem == .append     {imageName = "navi_append"}
        else if customItem == .search     {imageName = "navi_search"}
        else if customItem == .option     {imageName = "navi_option"}
        else if customItem == .message    {imageName = "navi_message"}
        else if customItem == .refresh    {imageName = "navi_refresh"}
        else if customItem == .none       {imageName = "navi_none"}
        else if customItem == .download   {imageName = "navi_download"}
        else                              {imageName = ""}
        
        let image = UIImage(named: "Resource.bundle/" + imageName)
        
        let button = UIButton()
        button.nnImage = image
        button.addTarget(target, action: action, for: .touchUpInside)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
    
    /// 尝试将customView作为UIButton输出
    var customViewAsButton: UIButton? {
        return self.customView as? UIButton
    }
}

extension UIViewController {
    
    @objc func naviback() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

var sharedAlertController : UIAlertController? = nil

extension UIAlertController {
    
    /// 添加UIAlertAction的便捷方法
    func addDefault(withTitle title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction(UIAlertAction(title: title, style: .default, handler: handler))
    }
    
    /// 添加UIAlertAction的便捷方法
    func addCancel(withTitle title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction(UIAlertAction(title: title, style: .cancel, handler: handler))
    }
    
    /// 添加UIAlertAction的便捷方法
    func addDestructive(withTitle title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction(UIAlertAction(title: title, style: .destructive, handler: handler))
    }
    
    /// 弹出提示框
    static func showAlert(withMessage message: String?) {
        return UIAlertController.showAlert(withTitle: nil, message: message, completion: nil)
    }
    
    /// 弹出提示框
    static func showAlert(withMessage message: String?, completion: (() -> Void)?) {
        return UIAlertController.showAlert(withTitle: nil, message: message, completion: completion)
    }
    
    /// 弹出提示框
    static func showAlert(withTitle title: String?, message: String?) {
        return UIAlertController.showAlert(withTitle: title, message: message, completion: nil)
    }
    
    /// 弹出提示框, 并设置点击确定后的事件
    static func showAlert(withTitle title: String?, message: String?, completion: (() -> Void)?) {
        if sharedAlertController != nil {
            NSLog("want to present an UIAlertController when it is exsited, so dismiss the old one")
            sharedAlertController?.dismiss(animated: false, completion: nil)
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addCancel(withTitle: "确定") { (action : UIAlertAction) in
            completion?()
            sharedAlertController = nil
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        sharedAlertController = alert
    }    
    
    /// 弹出询问框, 并设置点击确定后的事件
    static func showQuestion(withMessage message: String?, completion: (() -> Void)?) {
        return UIAlertController.showQuestion(withTitle: nil, message: message, completion: completion)
    }
    
    /// 弹出询问框, 并设置点击确定后的事件
    static func showQuestion(withTitle title: String?, message: String?, completion: (() -> Void)?) {
        if sharedAlertController != nil {
            NSLog("want to present an UIAlertController when it is exsited, so dismiss the old one")
            sharedAlertController?.dismiss(animated: false, completion: nil)
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addDefault(withTitle: "确定") { (action : UIAlertAction) in
            completion?()
            sharedAlertController = nil
        }
        alert.addCancel(withTitle: "取消") { (action : UIAlertAction) in
            sharedAlertController = nil
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        sharedAlertController = alert
    }
}

extension UIDevice {
    
    /// 这个设备是模拟器
    var isSimulator: Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }
    
    /// 这个设备是iPhoneX
    var iPhoneX: Bool {
        return UIScreen.main.bounds.height == 812
    }
}

/// 放光文字
class UIGlowLabel: UILabel {
    
    /// 发光区域的偏移
    var glowOffset : CGSize
    
    /// 发光区域的颜色
    var glowColor : UIColor
    
    /// 发光区域的长度
    var glowSize : CGFloat
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        self.glowOffset = CGSizeMake(0, 0)
        self.glowColor = UIColor.white
        self.glowSize = 2.0
        super.init(frame: frame)
    }
    
    override func drawText(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.setShadow(offset: self.glowOffset, blur: self.glowSize, color: self.glowColor.cgColor)
        super.drawText(in: rect)
        context.restoreGState()
    }
}

/// 带角标的UIImageView
class UIImageViewWithBadge: UIImageView {

    private let textLabel = UILabel()
    
    var badgeValue : String {
        set { textLabel.text = newValue }
        get { return textLabel.text ?? "" }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textAlignment = .right
        textLabel.font = UIFont.systemFont(ofSize: 8)
        addSubview(textLabel)
        NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: -10.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
