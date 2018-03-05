//
//  KosmosFoundation.swift
//  KosmosFoundation
//
//  Created by weizhen on 16/8/1.
//

import Foundation
import CoreLocation
import CoreGraphics

func +(left: CGFloat, right: Int) -> CGFloat { return left + CGFloat(right) }
func +(left: Int, right: CGFloat) -> CGFloat { return CGFloat(left) + right }
func -(left: CGFloat, right: Int) -> CGFloat { return left - CGFloat(right) }
func -(left: Int, right: CGFloat) -> CGFloat { return CGFloat(left) - right }
func *(left: CGFloat, right: Int) -> CGFloat { return left * CGFloat(right) }
func *(left: Int, right: CGFloat) -> CGFloat { return CGFloat(left) * right }
func /(left: CGFloat, right: Int) -> CGFloat { return left / CGFloat(right) }
func /(left: Int, right: CGFloat) -> CGFloat { return CGFloat(left) / right }

func +(left: Double, right: Int) -> Double { return left + Double(right) }
func +(left: Int, right: Double) -> Double { return Double(left) + right }
func -(left: Double, right: Int) -> Double { return left - Double(right) }
func -(left: Int, right: Double) -> Double { return Double(left) - right }
func *(left: Double, right: Int) -> Double { return left * Double(right) }
func *(left: Int, right: Double) -> Double { return Double(left) * right }
func /(left: Double, right: Int) -> Double { return left / Double(right) }
func /(left: Int, right: Double) -> Double { return Double(left) / right }

func KSLog(line: Int = #line, file: String = #file, function: String = #function, _ format: String, _ args: CVarArg...) {
    
    let formatLine = String.init(format: "%04d", line)
    
    var formatFile = file.components(separatedBy: "/").last!
    formatFile.removeLast(6)
    
    let codeLength = 50
    var codeMethod = "\(formatFile).\(function)"
    if codeMethod.count > codeLength {
       codeMethod = codeMethod.substring(from: 0, with: codeLength - 3) + "..."
    } else {
        while codeMethod.count < codeLength {
            codeMethod += " "
        }
    }
    
    let formatText = String.init(format: format, arguments: args)
    
    let formatDate = Date().string(using: "yyyy-MM-dd HH:mm:ss.SSS")
    
    print("[\(formatDate) \(formatLine)] \(formatText)")
    //print("[\(formatDate) \(formatLine) \(codeMethod)] \(formatText)")
}

extension Int {
    
    var asFloat : Float {
        return Float(self)
    }
    
    var asString : String {
        return String(describing: self)
    }
    
    var asDouble : Double {
        return Double(self)
    }
    
    var asCGFloat : CGFloat {
        return CGFloat(self)
    }
    
    var asNSNumber : NSNumber {
        return NSNumber(integerLiteral: self)
    }
}

extension UInt8 {
    
    func add(_ another: UInt8) -> UInt8 {
        return UInt8((Int(self) + Int(another)) & 0x000000FF)
    }
}

extension Int64 {
    
    var asString : String {
        return String(describing: self)
    }
}

extension Bool {
    
    var asString : String {
        return String(describing: self)
    }
}

extension Float {
    
    var asString : String {
        return String(describing: self)
    }
    
    var asCGFloat : CGFloat {
        return CGFloat(self)
    }
    
    var asInt : Int {
        return Int(self)
    }
}

extension Double {
    
    var asString : String {
        return String(describing: self)
    }
    
    var asCGFloat : CGFloat {
        return CGFloat(self)
    }
    
    var asFloat : Float {
        return Float(self) 
    }
    
    var asInt : Int {
        return Int(self)
    }
}

extension CGFloat {
    
    var asString : String {
        return String(describing: self)
    }
        
    var asInt : Int {
        return Int(self)
    }
    
    var asFloat : Float {
        return Float(self)
    }
    
    var asDouble : Double {
        return Double(self)
    }
    
    var asNSNumber : NSNumber {
        return NSNumber(floatLiteral: Double(self))
    }
}

extension NSNumber {
    
    var asString : String {
        return self.stringValue
    }
    
    var asInt : Int {
        return self.intValue
    }
    
    var asBool : Bool {
        return self.boolValue
    }
    
    var asFloat : Float {
        return self.floatValue
    }
    
    var asCGFloat : CGFloat {
        return self.floatValue.asCGFloat
    }
    
    /// 将整数转化为星期的描述
    var weekday : String {
        switch self.intValue {
        case 0:  return "星期日"
        case 1:  return "星期一"
        case 2:  return "星期二"
        case 3:  return "星期三"
        case 4:  return "星期四"
        case 5:  return "星期五"
        case 6:  return "星期六"
        default: return "无法解析"
        }
    }
    
    /// 将整数转化为星期的描述
    var shortWeekday : String {
        switch self.intValue {
        case 0:  return "日"
        case 1:  return "一"
        case 2:  return "二"
        case 3:  return "三"
        case 4:  return "四"
        case 5:  return "五"
        case 6:  return "六"
        default: return "无法解析"
        }
    }
    
    /// 将整数转化为十六进制字符串
    var hexString : String {
        return String(format: "%02x", self.intValue)
    }
    
    /// 将整数转化为布尔值的描述
    var boolString : String {
        return (self.intValue == 0) ? "false" : "true"
    }
    
    /// 将整数转化为布尔值的描述
    var BOOLString : String {
        return (self.intValue == 0) ? "YES" : "NO"
    }
}

enum NSPatternType : Int {
    case mobile            // 手机号码
    case phone             // 电话号码
    case email             // 电子邮箱
    case passowrd          // 密码 长度在6~32之间, 由小写字母、大写字母、阿拉伯数字、或下划线组成
    case citizenID         // 身份证号码
    case IPAddress         // IP地址
    case number            // 全是数字
    case URL               // URL地址
    case English           // 全是英文字母
    case Chinese           // 全是中文汉字
    case SMSCode           // 验证码
    case deviceName        // 设备名称
    case deviceIMEI        // 设备IMEI
    case deviceSIM         // 设备SIM
    case fenceName         // 围栏名称
    case balanceCmd        // 余额查询命令
    case remark            // 备注信息
}

extension String {
    
    var length : Int {
        return self.count
    }
    
    var asInt : Int {
        return Int(self) ?? 0
    }
    
    var asBool : Bool {
        if self.lowercased() == "true" {return true}
        if self.lowercased() == "yes" {return true}
        let int = Int(self) ?? 0
        return (int != 0)
    }
    
    var asFloat : Float {
        return Float(self) ?? 0.0
    }
    
    var asDouble : Double {
        return Double(self) ?? 0.0
    }
    
    var asCGFloat : CGFloat {
        return CGFloat(self.asFloat)
    }
    
    var asURL : URL? {
        return URL(string: self)
    }
    
    /// 输出一个随机的唯一标识符
    static var UUID : String {
        return NSUUID().uuidString
    }
    
    /// 去掉字符串头尾的空格
    var trim : String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 将String(base64格式)转为NSData
    var base64Decode : Data? {
        return Data(base64Encoded: self, options: .ignoreUnknownCharacters)
    }
    
    /// 将String以UTF8格式, 转为NSData
    var dataUsingUTF8 : Data? {
        return self.data(using: .utf8)
    }
    
    /// 输入类似"yyyy-MM-dd HH:mm:ss"的时间格式描述, 将String转为NSDate
    func date(using formatter: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        return dateFormatter.date(from: self)
    }
    
    /// 按照格式"yyyy-MM-dd HH:mm:ss", 将String转为NSDate
    var dateUsingDefault : Date? {
        return self.date(using: "yyyy-MM-dd HH:mm:ss")
    }
    
    /// "0011223344".nsrangeOf(string: "1122") = (location: 2, length: 4)
    func nsrangeOf(string aString: String) -> NSRange {
        return (self as NSString).range(of:aString)
    }

    /// "0011223344".substring(from: 4, with: 4) = "22334"
    func substring(from location: Int, with length: Int) -> String {
        let began = self.index(self.startIndex, offsetBy: location)
        let ended = self.index(self.startIndex, offsetBy: location + length)
        return String(self[began ..< ended])
    }
    
    /// "0011223344".substring(from: 4, to: 8) = "22334"
    func substring(from aFrom: Int, to aTo: Int) -> String {
        let began = self.index(self.startIndex, offsetBy: aFrom)
        let ended = self.index(self.startIndex, offsetBy: aTo + 1)
        return String(self[began ..< ended])
    }
    
    /// "0011223344".substring(from: 4) = "223344"
    func substring(from aFrom: Int) -> String {
        let began = self.index(self.startIndex, offsetBy: aFrom)
        return String(self[began...])
    }
    
    /// "0011223344".replace(from: 4, to: 8, with: "aabbcc") = "0011aabbcc4"
    func replace(from aFrom: Int, to aTo: Int, with aWith: String) -> String {
        let began = self.index(self.startIndex, offsetBy: aFrom)
        let ended = self.index(self.startIndex, offsetBy: aTo + 1)
        return self.replacingCharacters(in: began ..< ended, with: aWith)
    }
    
    /// " !!sw\ni ft".regularReplace(pattern: "\\s", with: "") = "!!swift"
    func regularReplace(pattern aPattern:String, options: NSRegularExpression.Options = [], matchingOptions: NSRegularExpression.MatchingOptions = [], with replacement: String) -> String {
        let regex = try! NSRegularExpression(pattern: aPattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: matchingOptions, range: NSMakeRange(0, self.length), withTemplate: replacement)
    }
    
    /// " !!sw\ni ft".regularSearch(pattern: "sw", with: "") = "sw"
    func regularSearch(pattern aPattern:String, options: NSRegularExpression.Options = [], matchingOptions: NSRegularExpression.MatchingOptions = []) -> String? {
        let regex = try! NSRegularExpression(pattern: aPattern, options: options)
        guard let result = regex.firstMatch(in: self, options: matchingOptions, range: NSMakeRange(0, self.length)) else { return nil }
        return self.substring(from: result.range.location, with: result.range.length)
    }
    
    /// 输出本地化字符串. self是作为key输入的
    var localizedString : String {
        let nation = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String] // 国家英文代码
        let folder = Bundle.main.bundlePath + "/strings.bundle" // 自定义的bundle
        let bundle = Bundle(path: folder)!
        return bundle.localizedString(forKey: self, value: nil, table: nation.first!)
    }
    
    /// 将汉字转化为拼音
    var pinyin : String {
        let ms = NSMutableString(string: self) as CFMutableString
        if CFStringTransform(ms, nil, kCFStringTransformMandarinLatin, false) {
            // ms = nǐ hǎo
        }
        if CFStringTransform(ms, nil, kCFStringTransformStripDiacritics, false) {
            // ms = ni hao
        }
        return ms as String
    }
    
    /** 判断当前字符串是否符合某种规则 */
    func isTypeOf(_ type: NSPatternType) -> Bool {
        
        let pattern : String
        if      type == .mobile      { pattern = "^1[34578]\\d{9}$" }
        else if type == .phone       { pattern = "^[0-9]{7,11}$" }
        else if type == .email       { pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" }
        else if type == .passowrd    { pattern = "^.{6,32}$" }
        else if type == .citizenID   { pattern = "^\\d{15}|\\d{18}$" }
        else if type == .IPAddress   { pattern = "((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)" }
        else if type == .number      { pattern = "^[0-9]*$" }
        else if type == .English     { pattern = "^[A-Za-z]+$" }
        else if type == .URL         { pattern = "\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))" }
        else if type == .Chinese     { pattern = "[\\u4e00-\\u9fa5]+" }
        else if type == .SMSCode     { pattern = "^\\d{6}$" }
        else if type == .deviceName  { pattern = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]{1,16}$" }
        else if type == .fenceName   { pattern = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]{1,16}$" }
        else if type == .deviceIMEI  { pattern = "^[0-9]{15}$" }
        else if type == .deviceSIM   { pattern = "^\\d{11,13}$" }
        else if type == .balanceCmd  { pattern = "^[a-zA-Z0-9]{1,8}$" }
        else if type == .remark      { pattern = "^.{1,60}$" }
        else                         { pattern = "" }
        
        if pattern.length == 0 {
            return false
        }
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let results = regex.matches(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, self.length))
            return results.count > 0
        }
        catch {
            return false
        }
    }
}

extension String.Encoding {
    
    /// GB18030
    public static var GB18030: String.Encoding  = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
}

extension Date {
    
    /// 将Date以某种格式转化为字符串
    func string(using formatter: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: self)
    }
    
    /// 将Date以预定格式转化为字符串
    var stringUsingDefault : String {
        return self.string(using: "yyyy-MM-dd HH:mm:ss")
    }
}

class NSTimePeriod: NSObject {
    
    /// 开始时刻
    var began : Date?
    
    /// 结束时刻
    var ended : Date?
    
    /// 持续时长
    var timeInterval : TimeInterval? {
        if let b = began, let e = ended {
            return e.timeIntervalSince(b)
        }
        return nil
    }
    
    /// 深拷贝
    func clone() -> NSTimePeriod {
        let obj = NSTimePeriod()
        obj.began = self.began
        obj.ended = self.ended
        return obj
    }
}

extension Data {

    /// 将Data按照某种编码格式, 转为String
    func stringUsing(encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }
        
    /// 将Data以UTF8格式, 转为String
    var stringUsingUTF8 : String? {
        return String(data: self, encoding: .utf8)
    }
    
    /// 将NSData转为String(base64格式)
    var base64Encode : String {
        return self.base64EncodedString(options: .lineLength64Characters)
    }
    
    /// 将NSData(json内容)转成AnyObject(其实是Array或者Dictionary)
    var asJSONObject : Any? {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: .mutableLeaves)
            return jsonObject
        } catch {
            NSLog("%@ error=%@", #function, error.localizedDescription)
            return nil
        }
    }
    
    /// 将Data转为JSON
    var asJSON : JSON {
        return JSON(self)
    }
    
    /// 将NSData转成十六进制字符串
    var hexString : String {
        return self.reduce("", { $0.appendingFormat("%02x", $1) })
    }
}

extension Array {
    
    var asJSONString : String? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0))
            let jsonText = String(data: jsonData, encoding: .utf8)
            return jsonText
        }
        catch {
            NSLog("%@ error = %@", #function, error.localizedDescription)
            return nil
        }
    }
}

extension Dictionary {
    
    var asJSONString : String? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0))
            let jsonText = String(data: jsonData, encoding: .utf8)
            return jsonText
        }
        catch {
            NSLog("%@ error = %@", #function, error.localizedDescription)
            return nil
        }
    }
}

extension URL {

}

extension Bundle {
    
    /// 输出Bundle版本
    static var shortVersion : String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    /// 输出Build版本
    static var buildVersion : String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    
    /// 输出Bundle目录
    static var bundleDirectory : String {
        return Bundle.main.bundlePath
    }
    
    /// 输出home目录
    static var homeDirectory : String {
        return NSHomeDirectory()
    }
    
    /// 输出document目录
    static var documentDirectory : String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    /// 输出temporary目录
    static var temporaryDirectory : String {
        return NSTemporaryDirectory()
    }
    
    /// 输出自定义目录
    static var customDirectory : String {
        let dstPath = NSHomeDirectory().appending("/custom")
        let fileManager = FileManager.default
        if fileManager.existsDirectory(at: dstPath) == nil {
            return fileManager.createDirectory(at: dstPath)!
        }
        return dstPath
    }
    
    /// 日志输出重定向
    static func redirectNSlogToDocumentFolder(_ filename: String) {
        let logFilePath = Bundle.documentDirectory.appendingFormat("/%@", filename)
        try? FileManager.default.removeItem(atPath: logFilePath)
        freopen(logFilePath.cString(using: .ascii), "w+", stdout)
        freopen(logFilePath.cString(using: .ascii), "w+", stderr)
    }
}

extension FileManager {
    
    func existsDirectory(at path: String) -> String? {
        
        var isDirectory = ObjCBool(false)
        
        let isExists = self.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if isExists == false {
            return nil
        }
        
        if isDirectory.boolValue == false {
            return nil
        }
        
        return path
    }
    
    func createDirectory(at path: String) -> String? {
        
        var isDirectory = ObjCBool(false)
        
        let isExists = self.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if isExists {
            return nil
        }
        
        if isDirectory.boolValue {
            return nil
        }
        
        do {
            try self.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: [FileAttributeKey.posixPermissions : 0777])
        } catch {
            return nil
        }
        
        return path
    }
    
    func removeDirectory(at path: String) -> String? {
        
        do {
            try self.removeItem(atPath: path)
        } catch {
            return nil
        }
        
        return path
    }
    
    func existsFile(at path: String) -> String? {
        
        var isDirectory = ObjCBool(false)
        
        let isExists = self.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if isExists == false {
            return nil
        }
        
        if isDirectory.boolValue == true {
            return nil
        }
        
        return path
    }
    
    func removeFile(at path: String) -> String? {
        
        do {
            try self.removeItem(atPath: path)
        } catch {
            return nil
        }
        
        return path
    }
}
