//
//  AppDelegate.swift
//  MyLifelog
//
//  Created by ucuc on 3/23/15.
//  Copyright (c) 2015 ucuc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        //Notification登録前のおまじない。テストの為、現在のノーティフケーションを削除します
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        //Notification登録前のおまじない。これがないとpermissionエラーが発生するので必要です。
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let string = formatter.stringFromDate(now)
        println(string)
        
        // バッジの数をインクリメント
        UIApplication.sharedApplication().applicationIconBadgeNumber++
        
        //以下で登録処理
        var localNotification : UILocalNotification = UILocalNotification()
        localNotification.alertAction = "OK"
        var brightness = UIScreen.mainScreen().brightness
        // localNotification.alertBody = "Called application:performFetchWithCompletionHandler:"
        localNotification.alertBody = "brightness -> "+brightness.description
        localNotification.fireDate = NSDate() // NSDate date // NSDate(timeIntervalSinceNow: 5);//５秒後
        localNotification.timeZone = NSTimeZone.defaultTimeZone() // localTimeZone
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification);

        // ダウンロード完了
        // completionHandler(UIBackgroundFetchResultNoData);
        completionHandler(UIBackgroundFetchResult.NewData)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        // バッジの数をリセット
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

