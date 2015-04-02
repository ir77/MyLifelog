//
//  ViewController.swift
//  MyLifelog
//
//  Created by ucuc on 3/23/15.
//  Copyright (c) 2015 ucuc. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import Parse

struct ParseData {
    static var applicationId : String!
    static var clientKey : String!
    static var preBrightness : CGFloat!
    static var brightnessDict : [Dictionary<String, String>]!
}

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var myLabel: UILabel!
    var locManager: CLLocationManager?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var brightness = UIScreen.mainScreen().brightness
        ParseData.preBrightness = brightness
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenBrightnessDidChange:", name: UIScreenBrightnessDidChangeNotification, object: nil)
        self.myLabel.text = brightness.description
        setupParse()
        ParseData.brightnessDict = []

        self.setupLocationManager()
    }
    func screenBrightnessDidChange(notification:NSNotification){
        var screen : UIScreen = notification.object as UIScreen
        self.myLabel.text = screen.brightness.description
    }

    // MARK: - Parse
    func setupParse () -> Bool {
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("private", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            ParseData.applicationId = dict["applicationId"] as String
            ParseData.clientKey = dict["clientKey"] as String
            Parse.enableLocalDatastore()
            Parse.setApplicationId(ParseData.applicationId, clientKey: ParseData.clientKey)
            return true
        }
        return false
    }
    func saveBrightnessDataInParse () {
        if !checkBrightnessChange() {
            return
        }
        
        if (ParseData.brightnessDict.count >= 10) {
            var objects : [PFObject] = []
            for var i=0; i<ParseData.brightnessDict.count; i++ {
                let pfObject : PFObject = PFObject(className: "TestObject")
                pfObject["brightness"] = ParseData.brightnessDict[i]["brightness"]
                pfObject["localtime"] = ParseData.brightnessDict[i]["localtime"]
                objects.append(pfObject)
                /*
                testObject.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError!) -> Void in
                    if (success) {
                        // The object has been saved.
                        println("success")
                    } else {
                        // There was a problem, check error.description
                        println("error")
                    }
                }*/
            }
            PFObject.saveAllInBackground(objects, block: {
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    // The object has been saved.
                    println("success")
                    ParseData.brightnessDict = []
                } else {
                    // There was a problem, check error.description
                    println("error")
                }
            })
        }
    }
    func checkBrightnessChange () -> Bool {
        let brightnessDiff =  abs(ParseData.preBrightness - UIScreen.mainScreen().brightness)
        if (brightnessDiff >= 0.1) {
            ParseData.preBrightness = UIScreen.mainScreen().brightness
            let now = NSDate() // 現在日時の取得
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
            dateFormatter.timeStyle = .LongStyle
            dateFormatter.dateStyle = .LongStyle
            println(dateFormatter.stringFromDate(now)) // -> 2014年6月24日 11:14:17 JST
            let tmpDict: Dictionary<String, String> = ["brightness": UIScreen.mainScreen().brightness.description, "localtime":dateFormatter.stringFromDate(now)]
            ParseData.brightnessDict.append(tmpDict)
            println(ParseData.brightnessDict)
            return true
        }
        return false
    }
    
    // MARK: - Location
    func setupLocationManager () {
        self.locManager = CLLocationManager();
        self.locManager!.delegate = self;
        if (!CLLocationManager.locationServicesEnabled()) {
            println("Location services are not enabled");
        }
        self.locManager!.requestAlwaysAuthorization();
        self.locManager!.pausesLocationUpdatesAutomatically = false;
        self.locManager!.startUpdatingLocation()
    }
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        // println(newLocation.timestamp)
        saveBrightnessDataInParse()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

