//
//  SlickCategoryStorage.swift
//  SlickNotes
//
//  Created by user166476 on 6/19/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import UIKit
import CoreData

class SlickCategoryStorage {
    static let storage : SlickCategoryStorage = SlickCategoryStorage()
    
    private var categoryIndexToIdDict : [Int:UUID] = [:]
    private var currentIndex : Int = 0

    private(set) var managedObjectContext : NSManagedObjectContext
    private var managedContextHasBeenSet : Bool = false
    
    private init() {
        // we need to init our ManagedObjectContext
        // This will be overwritten when setManagedContext is called from the view controller.
        managedObjectContext = NSManagedObjectContext(
            concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    }
    
    func setManagedContext(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.managedContextHasBeenSet = true
        let categories = SlickCategoryCoreDataHelper.readCategoriesFromCoreData(fromManagedObjectContext: self.managedObjectContext)
        currentIndex = SlickCategoryCoreDataHelper.count
        for (index, category) in categories.enumerated() {
            categoryIndexToIdDict[index] = category.categoryId
            }
        }
    
    
    func addCategory(categoryToBeAdded: SlickCategory) {
        if managedContextHasBeenSet {
            // add note UUID to the dictionary
            categoryIndexToIdDict[currentIndex] = categoryToBeAdded.categoryId
            SlickCategoryCoreDataHelper.createCategoryInCoreData(categoryToBeCreated: categoryToBeAdded, intoManagedObjectContext: self.managedObjectContext)
            // increase index
            currentIndex += 1
        }
    }
    
    func removeCategory(at: Int) {
        if managedContextHasBeenSet {
            // check input index
            if at < 0 || at > currentIndex-1 {
                // TODO error handling
                return
            }
            // get note UUID from the dictionary
            let categoryUUID = categoryIndexToIdDict[at]
            SlickCategoryCoreDataHelper.deleteCategoryFromCoreData(categoryIdToBeDeleted: categoryUUID!, fromManagedObjectContext: self.managedObjectContext)
            // update noteIndexToIdDict dictionary
            // the element we removed was not the last one: update GUID's
            if (at < currentIndex - 1) {
                // currentIndex - 1 is the index of the last element
                // but we will remove the last element, so the loop goes only
                // until the index of the element before the last element
                // which is currentIndex - 2
                for i in at ... currentIndex - 2 {
                    categoryIndexToIdDict[i] = categoryIndexToIdDict[i+1]
                }
            }
            // remove the last element
            categoryIndexToIdDict.removeValue(forKey: currentIndex)
            // decrease current index
            currentIndex -= 1
        }
    }
    
    func readCategory(at: Int) -> SlickCategory? {
        if managedContextHasBeenSet {
            // check input index
            if at < 0 || at > currentIndex-1 {
                // TODO error handling
                return nil
            }
            // get note UUID from the dictionary
            let categoryUUID = categoryIndexToIdDict[at]
            let categoryReadFromCoreData: SlickCategory?
            categoryReadFromCoreData = SlickCategoryCoreDataHelper.readCatetgoryFromCoreData(categoryIdToBeRead: categoryUUID!, fromManagedObjectContext: self.managedObjectContext)
            return categoryReadFromCoreData
        }
        return nil
    }
    
    
    func readCategories(withPredicate: NSPredicate? = nil) -> [SlickCategory]?{
        
        if managedContextHasBeenSet {
            return SlickCategoryCoreDataHelper.readCategoriesFromCoreData(fromManagedObjectContext: self.managedObjectContext, withPredicate: withPredicate)
       }
       return nil
        
    }
    
    func changeCategory(categoryToBeChanged: SlickCategory) {
        if managedContextHasBeenSet {
            // check if UUID is in the dictionary
            var categoryToBeChangedIndex : Int?
            categoryIndexToIdDict.forEach { (index: Int, categoryId: UUID) in
                if categoryId == categoryToBeChanged.categoryId {
                    categoryToBeChangedIndex = index
                    return
                }
            }
            if categoryToBeChangedIndex != nil {
                SlickCategoryCoreDataHelper.changeCategoryInCoreData(categoryToBeChanged: categoryToBeChanged, inManagedObjectContext: self.managedObjectContext)
            } else {
                // TODO error handling
            }
        }
    }
    func count() -> Int {
        print(SlickCategoryCoreDataHelper.count)
        return SlickCategoryCoreDataHelper.count
    }
}
