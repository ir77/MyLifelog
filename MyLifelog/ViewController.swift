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

struct ParseSetting {
    static var applicationId : String!
    static var clientKey : String!
    static var preBrightness : CGFloat!
}

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var myLabel: UILabel!
    var locManager: CLLocationManager?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var brightness = UIScreen.mainScreen().brightness
        ParseSetting.preBrightness = brightness
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenBrightnessDidChange:", name: UIScreenBrightnessDidChangeNotification, object: nil)
        self.myLabel.text = brightness.description
        setupParse()
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
            ParseSetting.applicationId = dict["applicationId"] as String
            ParseSetting.clientKey = dict["clientKey"] as String
            Parse.enableLocalDatastore()
            Parse.setApplicationId(ParseSetting.applicationId, clientKey: ParseSetting.clientKey)
            return true
        }
        return false
    }
    func saveBrightnessDataInParse () {
        if !checkBrightnessChange() {
            return
        }
        let testObject = PFObject(className: "TestObject")
        testObject["foo"] = UIScreen.mainScreen().brightness.description
        testObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                // The object has been saved.
                println("success")
            } else {
                // There was a problem, check error.description
                println("error")
            }
        }
    }
    func checkBrightnessChange () -> Bool {
        let brightnessDiff =  abs(ParseSetting.preBrightness - UIScreen.mainScreen().brightness)
        if (brightnessDiff >= 0.2) {
            ParseSetting.preBrightness = UIScreen.mainScreen().brightness
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
        println(newLocation.timestamp)
        var brightness = UIScreen.mainScreen().brightness
        println(brightness.description)
    }
    
    func screenBrightnessDidChange(notification:NSNotification){
        var screen : UIScreen = notification.object as UIScreen
        self.myLabel.text = screen.brightness.description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

