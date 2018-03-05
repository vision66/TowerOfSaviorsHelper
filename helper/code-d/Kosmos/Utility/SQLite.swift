//
//  SQLite.swift
//  demo
//
//  Created by weizhen on 2017/8/3.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import Foundation
import SQLite3

fileprivate let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
fileprivate let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// 封装的SQLite对象
class SQLite: NSObject {
    
    /// 数据库指针
    private var database : OpaquePointer? = nil
    
    /// 时间格式
    let dateFormatter = DateFormatter()
    
    /// 打开数据库
    @discardableResult
    func open(in path : String) -> Int32 {
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let cPath = path.cString(using: String.Encoding.utf8)
        
        return sqlite3_open_v2(cPath, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil)
    }
    
    /// 关闭数据库
    func shut() {
        if let mydb = database {
            sqlite3_close(mydb)
        }
        database = nil
    }
    
    /// 执行SQL语句
    @discardableResult
    func update(_ formatSQL: Any?...) -> Int32 {
        
        guard formatSQL.count > 0, let SQL = formatSQL.first as? String else {
            print("SQLite: parameter error")
            return SQLITE_INTERNAL
        }
        
        var stmt : OpaquePointer? = nil
        
        let cSQL = SQL.cString(using: .utf8)
        
        var result = sqlite3_prepare_v2(database, cSQL, -1, &stmt, nil)
        if result != SQLITE_OK {
            print("SQLite: sqlite3_prepare_v2 error = \(result), sql=\(SQL)")
            return result
        }
        
        let bindCount = sqlite3_bind_parameter_count(stmt)
        if Int(bindCount) > formatSQL.count - 1 {
            print("SQLite: parameter error")
            return SQLITE_INTERNAL
        }
        
        for idx in 0 ..< bindCount {
            
            let col = idx + 1
            
            let obj = formatSQL[Int(col)]
            
            result = self.bindObject(obj, toColumn: col, inStatement: stmt)
            if result != SQLITE_OK {
                print("SQLite: bindObject error = \(result), sql=\(SQL)")
                sqlite3_finalize(stmt)
                return result
            }
        }
        
        result = sqlite3_step(stmt)
        if result != SQLITE_DONE {
            print("SQLite: sqlite3_step error = \(result), sql=\(SQL)")
        }
        
        result = sqlite3_finalize(stmt)
        if result != SQLITE_OK {
            print("SQLite: sqlite3_finalize error = \(result), sql=\(SQL)")
        }
        
        return result
    }
    
    /// 执行SQL语句
    func search(_ formatSQL: Any?...) -> [[String : Any]] {
        
        guard formatSQL.count > 0, let SQL = formatSQL.first as? String else {
            print("SQLite: parameter error")
            return []
        }
        
        var stmt : OpaquePointer? = nil
        
        let cSQL = SQL.cString(using: String.Encoding.utf8)
        
        var result = sqlite3_prepare_v2(database, cSQL, -1, &stmt, nil)
        if result != SQLITE_OK {
            print("SQLite: sqlite3_prepare_v2 error = \(result), sql=\(SQL)")
            return []
        }
        
        let bindCount = sqlite3_bind_parameter_count(stmt)
        if Int(bindCount) > formatSQL.count - 1 {
            print("SQLite: parameter error")
            return []
        }
        
        for idx in 0 ..< bindCount {
            
            let col = idx + 1
            
            let obj = formatSQL[Int(col)]
            
            result = self.bindObject(obj, toColumn: col, inStatement: stmt)
            if result != SQLITE_OK {
                print("SQLite: bindObject error = \(result), sql=\(SQL)")
                sqlite3_finalize(stmt)
                return []
            }
        }
        
        var rows = [[String : Any]]()
        
        while (SQLITE_ROW == sqlite3_step(stmt)) {
            
            let columnCount = sqlite3_column_count(stmt);
            
            var row = [String : Any]()
            
            for columnIdx in 0 ..< columnCount {
                
                let columnType = sqlite3_column_type(stmt, columnIdx);
                
                var columnValue : Any? = nil
                
                switch (columnType) {
                    
                case SQLITE_NULL:
                    columnValue = NSNull()
                    
                case SQLITE_INTEGER:
                    
                    let value = sqlite3_column_int(stmt, columnIdx)
                    columnValue = Int(value)
                    
                case SQLITE_FLOAT:
                    
                    let value = sqlite3_column_double(stmt, columnIdx)
                    columnValue = value
                    
                case SQLITE3_TEXT:
                    
                    if let value = sqlite3_column_text(stmt, columnIdx) {
                        columnValue =  String(cString: value)
                    } else {
                        columnValue = ""
                    }
                    
                default:
                    NSLog("SQLite: unknown column")
                }
                
                if let colValue = columnValue {
                    let cKey = sqlite3_column_name(stmt, columnIdx)
                    let sKey = String(validatingUTF8: cKey!)!
                    row[sKey] = colValue
                }
            }
            
            if row.count > 0 {
                rows.append(row)
            }
        }
        
        result = sqlite3_finalize(stmt)
        if result != SQLITE_OK {
            print("SQLite: sqlite3_finalize error = \(result), sql=\(SQL)")
        }
        
        return rows
    }
    
    /// 绑定的索引是从1开始算起, 
    ///   从formatSQL输入的数据类型可以是: nil, Bool, String, Float, Double, Int, Date
    ///   输入到数据库的类型只会有: null, int, double, text
    ///   从数据库输出的类型只会有: NSNull, Int, Double, String
    private func bindObject(_ obj: Any?, toColumn idx: Int32, inStatement stmt: OpaquePointer?) -> Int32 {
        
        if obj == nil {
            return sqlite3_bind_null(stmt, idx);
        }
        
        if let obj = obj as? Bool {
            return sqlite3_bind_int(stmt, idx, Int32(obj ? 1 : 0))
        }
        
        if let obj = obj as? Int {
            return sqlite3_bind_int(stmt, idx, Int32(obj))
        }
        
        if let obj = obj as? Float {
            return sqlite3_bind_double(stmt, idx, Double(obj))
        }
        
        if let obj = obj as? Double {
            return sqlite3_bind_double(stmt, idx, Double(obj))
        }

        if let obj = obj as? String {
            let cString = obj.cString(using: .utf8)
            return sqlite3_bind_text(stmt, idx, cString, -1, SQLITE_TRANSIENT)
        }
        
        if let obj = obj as? Date {
            let cString = self.dateFormatter.string(from: obj).cString(using: .utf8)!
            return sqlite3_bind_text(stmt, idx, cString, -1, SQLITE_TRANSIENT)
        }
        
        return SQLITE_INTERNAL
    }
}
