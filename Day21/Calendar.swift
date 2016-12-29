//
//  Calendar.swift
//  Rabbit days
//
//  Created by Christian on 7/7/15.
//  Copyright (c) 2015 AloaLabs. All rights reserved.
//

import UIKit
import CoreData

class Calendar: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var entryCalendarTable: UITableView!
    @IBOutlet weak var noentriesMessage: UIImageView!
    
    var days = [Date]()
    var dayData = [NSManagedObject]()
    var colors = [UIColor]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        loadDates()
        loadColors()
        checkIfClear()
    }
    
    func checkIfClear() {
        // Check if they are all clear
        if(days.count == 0) {
            NSLog("all clear")
            NSLog("day data is \(self.dayData.count)")
            noentriesMessage.isHidden = false
            entryCalendarTable.isHidden = true
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        noentriesMessage.isHidden = true
        entryCalendarTable.isHidden = false
        
        
        entryCalendarTable.delegate = self
        entryCalendarTable.dataSource = self
        
        loadDates()
        loadColors()
        checkIfClear()
        
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(Calendar.swipeRight(_:)))
        recognizer.direction = .right
        self.view .addGestureRecognizer(recognizer)
        
    }
    
    func swipeRight(_ recognizer : UISwipeGestureRecognizer) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func loadDates() {
        self.days.removeAll(keepingCapacity: false)
        self.dayData.removeAll(keepingCapacity: false)
        let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        
        var error: NSError?
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            var entries = results as! [NSManagedObject]
            self.dayData = results as! [NSManagedObject]
            loadDays()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    func loadDays() {
        self.days.removeAll(keepingCapacity: false)
        for day in dayData {
            var valuesFound = [String]()
            let attributes = day.entity.attributesByName
            for (key, value) in attributes {
                if let value = day.value(forKey: key ) as? NSString {
                    valuesFound.append(value as String)
                }
            }
            if let date = day.value(forKey: "date") as? Date {
                if(valuesFound.count > 0) {
                    NSLog("the value count is \(valuesFound.count) date is \(date)")
                    self.days.append(date)
                }
            }
        }
    }
    
    func loadColors() {
        self.colors.removeAll(keepingCapacity: false)
        let colorGenerator = ColorGenerator(hue: 0.4, saturation: 0.8, brightness: 0.9, alpha: 1.0, increment: 0.02)
        for item in days {
            self.colors.append(colorGenerator.next()!)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specDay = self.dayData[(indexPath as NSIndexPath).row]
        let moreDetail = self.storyboard!.instantiateViewController(withIdentifier: "singleDay") as! SingleDay
        
        moreDetail.dayObject = specDay
        
        //self.presentViewController(newEntry, animated: true, completion: nil)
        // self.navigationController?.presentViewController(newEntry, animated: true, completion: nil)
        self.navigationController?.pushViewController(moreDetail, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return  self.days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainCell
        cell.selectionStyle = .none
        let item = self.days[(indexPath as NSIndexPath).row]
        cell.backgroundColor = colors[(indexPath as NSIndexPath).row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d YYYY"
        let date = dateFormatter.string(from: item) as NSString
        
        cell.food.text = "\(date)"
        
        return cell
    }
    
}
