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

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var myLabel: UILabel!
    var myMotionManager: CMMotionManager!
    var locManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var brightness = UIScreen.mainScreen().brightness
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenBrightnessDidChange:", name: UIScreenBrightnessDidChangeNotification, object: nil)
        self.myLabel.text = brightness.description
        self.setupLocationManager()
        self.setupParse()
    }
    
    func setupParse () {
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("private", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            let applicationId = dict["applicationId"] as String
            let clientKey = dict["clientKey"] as String
            Parse.enableLocalDatastore()
            Parse.setApplicationId(applicationId, clientKey: clientKey)
            
            let testObject = PFObject(className: "TestObject")
            testObject["foo"] = "bar"
            testObject.save()
        }
    }
    
    func setupLocationManager () {
        self.locManager = CLLocationManager();
        self.locManager!.delegate = self;
        if (!CLLocationManager.locationServicesEnabled()) {
            println("Location services are not enabled");
        }
        self.locManager!.requestAlwaysAuthorization();
        self.locManager!.pausesLocationUpdatesAutomatically = false;
        self.locManager!.startUpdatingLocation()
        
        // MotionManagerを生成.
        myMotionManager = CMMotionManager()
        
        // 更新周期を設定.
        myMotionManager.accelerometerUpdateInterval = 0.5
        
        // 加速度の取得を開始.
        myMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(accelerometerData:CMAccelerometerData!, error:NSError!) -> Void in
            println(accelerometerData.acceleration.x)
        })
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        println(newLocation.timestamp)
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

