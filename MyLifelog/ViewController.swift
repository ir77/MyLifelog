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
        let brightnessCGFloat = UIScreen.mainScreen().brightness
        let brightnessDouble = Double(brightnessCGFloat)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenBrightnessDidChange:", name: UIScreenBrightnessDidChangeNotification, object: nil)
        self.myLabel.text = "\(brightnessDouble)"

        ParseData.brightnessDict = []
        ParseData.brightnessDict.append(self.getBrightnessDict())

        ParseData.parseObject = MyParse()
        ParseData.parseObject.delegate = self
        
        self.setupLocationManager()
    }
    func screenBrightnessDidChange(notification:NSNotification){
        let screen : UIScreen = notification.object as UIScreen
        let brightnessDouble = Double(screen.brightness)
        self.myLabel.text = "\(brightnessDouble)"
    }

    func checkBrightnessChange () {
        let count = ParseData.brightnessDict.count
        if count == 0 {
            return
        }
        let brightnessStr = ParseData.brightnessDict[count-1]["brightness"]
        let brightnessDiff =  abs(getDoubleFromString(brightnessStr!) - Double(UIScreen.mainScreen().brightness))
        if (brightnessDiff >= 0.1) {
            ParseData.brightnessDict.append(self.getBrightnessDict())
            println(ParseData.brightnessDict)
        } else if brightnessDiff < 0.1 {
            if (ParseData.brightnessDict.count >= 2) {
                let brightnessStr2 = ParseData.brightnessDict[count-2]["brightness"]
                let brightnessDiff2 =  abs(getDoubleFromString(brightnessStr2!) - Double(UIScreen.mainScreen().brightness))
                if brightnessDiff2 < 0.1 {
                    ParseData.brightnessDict[count-1]["localtime"] = getNowDate()
                    println(ParseData.brightnessDict)
                } else {
                    ParseData.brightnessDict.append(self.getBrightnessDict())
                    println(ParseData.brightnessDict)
                }
            } else {
                ParseData.brightnessDict.append(self.getBrightnessDict())
                println(ParseData.brightnessDict)
            }
        }
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
        println(getNowDate())
        checkBrightnessChange()
        if ParseData.brightnessDict.count >= 10 {
            println(ParseData.brightnessDict)
            ParseData.parseObject.saveBrightnessDataInParse(ParseData.brightnessDict)
        }
    }
    
    func getDoubleFromString (str : String) -> Double {
        return Double(NSNumberFormatter().numberFromString(str)!)
    }
    
    func getBrightnessDict () -> Dictionary<String, String> {
        let tmpDict: Dictionary<String, String> = ["brightness": UIScreen.mainScreen().brightness.description, "localtime":self.getNowDate()]
        return tmpDict
    }
    
    func getNowDate () -> String {
        let now = NSDate() // 現在日時の取得
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(now)
    }
    
    func saveBackgroundSuccess() -> Void {
        ParseData.brightnessDict = []
        ParseData.brightnessDict.append(getBrightnessDict())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

