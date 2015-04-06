//
//  MyParse.swift
//  MyLifelog
//
//  Created by ucuc on 4/2/15.
//  Copyright (c) 2015 ucuc. All rights reserved.
//

import Parse

protocol MyParseDelegate {
    func saveBackgroundSuccess() -> Void
}

class MyParse {
    var delegate: MyParseDelegate!
    
    init () {
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("private", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            let applicationId = dict["applicationId"] as String
            let clientKey = dict["clientKey"] as String
            Parse.enableLocalDatastore()
            Parse.setApplicationId(applicationId, clientKey: clientKey)
        }
    }
    
    func saveBrightnessDataInParse (brightnessDict:[Dictionary<String, String>]) {
        var objects : [PFObject] = []
        for var i=0; i<brightnessDict.count; i++ {
            let pfObject : PFObject = PFObject(className: "TestObject")
            pfObject["brightness"] = brightnessDict[i]["brightness"]
            pfObject["localtime"] = brightnessDict[i]["localtime"]
            objects.append(pfObject)
        }
        PFObject.saveAllInBackground(objects, block: {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                // The object has been saved.
                println("success")
                self.delegate.saveBackgroundSuccess()
            } else {
                // There was a problem, check error.description
                println(error.description)
            }
        })
    }
    
    func saveErrorData (brightness:CGFloat) {
        var data = PFObject(className:"error")
        if (brightness > 1.0) {
            data["error"] = true
        }
        data["CGFloat"] = brightness
        data["Double"] = Double(brightness)
        data["Double2"] = Double(Int(brightness * 1000.0)) / 1000.0
        
        data.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                println("success error save")
            }
        }
    }
}