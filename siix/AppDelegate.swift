//
//  AppDelegate.swift
//  siix
//
//  Created by Kingnez on 16/6/3.
//  Copyright © 2016年 diqi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let displayMenuItem = NSMenuItem(title: "暂停", action: #selector(AppDelegate.toggleCountdown(_:)), keyEquivalent: "")
    
    var workTime = 60 * 45
    var isActive = false
    var secsLeft: Int?
    var timer: NSTimer?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: #selector(AppDelegate.receiveSleepNote(_:)), name: NSWorkspaceScreensDidSleepNotification, object: nil)
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: #selector(AppDelegate.receiveWakeNote(_:)), name: NSWorkspaceScreensDidWakeNotification, object: nil)
        
        if let button = statusItem.button {
            button.image = NSImage(named: "66")
        }
        
        let menu = NSMenu()
        menu.addItem(displayMenuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(AppDelegate.quit(_:)), keyEquivalent: ""))
        statusItem.menu = menu
        
        secsLeft = workTime
        startCountdown()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        stopCountdown()
    }

    func toggleCountdown(sender: AnyObject) {
        isActive = !isActive
        if isActive {
            startCountdown()
        } else {
            stopCountdown()
        }
        displayMenuItem.title = (isActive ? "暂停" : "恢复") + displayCountdown(secsLeft!)
    }
    
    func quit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func receiveSleepNote(note: NSNotification) {
        stopCountdown()
    }
    
    func receiveWakeNote(note: NSNotification) {
        secsLeft = workTime
        startCountdown()
    }
    
    func startCountdown() {
        stopCountdown()
        timer = NSTimer.init(timeInterval: 1, target: self, selector: #selector(AppDelegate.countdown(_:)), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        isActive = true
    }
    
    func stopCountdown() {
        if timer != nil {
            timer!.invalidate()
        }
        isActive = false
    }
    
    func countdown(timer: NSTimer) {
        secsLeft = secsLeft! - 1
        displayMenuItem.title = (isActive ? "暂停" : "恢复") + displayCountdown(secsLeft!)
        if secsLeft <= 0 {
            stopCountdown()
            displaySleep()
        }
    }
    
    func displaySleep() {
        let task = NSTask()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["pmset", "displaysleepnow"]
        task.launch()
    }
    
    func displayCountdown(secs: Int) -> String {
        return "（" + String(format: "%02d", arguments: [secs / 60]) + ":" + String(format: "%02d", arguments: [secs % 60]) + "）"
    }

}

