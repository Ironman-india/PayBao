//
//  CSVReader.swift
//  PayBao
//
//  Created by Senchan on 16/6/22.
//  Copyright © 2016年 Senchan. All rights reserved.
//

import Foundation
import SwiftCSV

class Data:NSObject {
    var date:timeval?
    var event:String?
    var who:String?
    var cost:String?
}

/**
 CSVReader
 - parameter fileName: data.csv
 - parameter completionHandle: completionHandle
 */

class CSVReader {
    /**
     CSV读取
     
     - parameter fileName:         文件名
     - parameter completionHandle: completionHandle
     */
    class func loadDataFromCSV<T:NSObject>(fileName:String,completionHandle:([T])->Void){
        //异步读取
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "csv")
            let csvURL = NSURL(fileURLWithPath: filePath!)
            do{
                let csv = try CSV(url: csvURL)
                let dataArray = csv.rows.map({ (dic:[String:String]) -> T in
                    let data = T()
                    dic.forEach({ (key,value) in
                        data.setValue(value, forKey: key)
                    })
                    return data
                })
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandle(dataArray)
                })
            }catch{
                completionHandle([])
            }
        })
    }
}


class CSVDataManager{
    static let sharedInstance = CSVDataManager()
    var dataArray:[Data]?
    func loadData(completionHandle:([Data])->Void) {
        if let data = dataArray{
            completionHandle(data)
        }else{
            CSVReader.loadDataFromCSV("data", completionHandle: { (data:[Data]) in
                self.dataArray =  data
                completionHandle(data)
            })
        }
    }
}