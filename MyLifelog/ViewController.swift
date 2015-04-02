//
//  ViewController.swift
//  MyLifelog
//
//  Created by ucuc on 3/23/15.
//  Copyright (c) 2015 ucuc. All rights reserved.
//

import UIKit
import CoreLocation

private struct ParseData {
    static var preBrightness : CGFloat!
    static var brightnessDict : [Dictionary<String, String>]!
    static var parseObject : MyParse!
}

class ViewController: UIViewController, CLLocationManagerDelegate, MyParseDelegate {

    @IBOutlet weak var myLabel: UILabel!
    var locManager: CLLocationManager?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var brightness = UIScreen.mainScreen().brightness
        ParseData.preBrightness = brightness
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenBrightnessDidChange:", name: UIScreenBrightnessDidChangeNotification, object: nil)
        self.myLabel.text = "\(brightness)"
        ParseData.parseObject = MyParse()
        ParseData.parseObject.delegate = self
        ParseData.brightnessDict = []
        self.setupLocationManager()
    }
    func screenBrightnessDidChange(notification:NSNotification){
        var screen : UIScreen = notification.object as UIScreen
        self.myLabel.text = "\(screen.brightness)"
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
        if checkBrightnessChange() {
            ParseData.parseObject.saveBrightnessDataInParse(ParseData.brightnessDict)
        }
    }
    
    func saveBackgroundSuccess() -> Void {
        ParseData.brightnessDict = []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

