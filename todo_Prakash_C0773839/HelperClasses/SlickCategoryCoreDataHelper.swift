//
//  SlickCategoryCoreDataHelper.swift
//  SlickNotes
//
//  Created by Prakash on 2020-06-22.
//  Copyright © 2020 Quasars. All rights reserved.
//

import Foundation
//
//  SlickNotesCoreDataHelper.swift
//  SlickNotes
//
//  Created by user166476 on 6/20/20.
//  Copyright © 2020 Quasars. All rights reserved.
//

import Foundation
import CoreData

class SlickCategoryCoreDataHelper
{
    private(set) static var count: Int = 0
    
    static func createCategoryInCoreData(
        categoryToBeCreated:   SlickCategory,
        intoManagedObjectContext: NSManagedObjectContext) {
        
        // Let’s create an entity and new note record
        let categoryEntity = NSEntityDescription.entity(
            forEntityName: "Category",
            in:            intoManagedObjectContext)!
        
        let newCategoryToBeCreated = NSManagedObject(
            entity:     categoryEntity,
            insertInto: intoManagedObjectContext)

        newCategoryToBeCreated.setValue(
            categoryToBeCreated.categoryId,
            forKey: "categoryId")
        
        newCategoryToBeCreated.setValue(
            categoryToBeCreated.categoryName,
            forKey: "categoryName")
        
       
        
        do {
            try intoManagedObjectContext.save()
            count += 1
        } catch let error as NSError {
            // TODO error handling
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func changeCategoryInCoreData(
        categoryToBeChanged:        SlickCategory,
        inManagedObjectContext: NSManagedObjectContext) {
        
        // read managed object
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        
        let categoryIdPredicate = NSPredicate(format: "categoryId = %@", categoryToBeChanged.categoryId as CVarArg)
        
        fetchRequest.predicate = categoryIdPredicate
        
        do {
            let fetchedCategoryFromCoreData = try inManagedObjectContext.fetch(fetchRequest)
            let categoryManagedObjectToBeChanged = fetchedCategoryFromCoreData[0] as! NSManagedObject
            
            // make the changes
            categoryManagedObjectToBeChanged.setValue(
                categoryToBeChanged.categoryName,
                forKey: "categoryName")


            // save
            try inManagedObjectContext.save()

        } catch let error as NSError {
            // TODO error handling
            print("Could not change. \(error), \(error.userInfo)")
        }
    }
    
    
    static func readCategoriesFromCoreData(fromManagedObjectContext: NSManagedObjectContext) -> [SlickCategory]{
        
        var returnedCategories = [SlickCategory]()
               
               let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
               fetchRequest.predicate = nil
               
               do {
                   let fetchedCategoriesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
                   fetchedCategoriesFromCoreData.forEach { (fetchRequestResult) in
                       let categoryManagedObjectRead = fetchRequestResult as! NSManagedObject
                       returnedCategories.append(SlickCategory.init(categoryId: categoryManagedObjectRead.value(forKey: "categoryId") as! UUID, categoryName: categoryManagedObjectRead.value(forKey: "categoryName") as! String))
                   }
               } catch let error as NSError {
                   // TODO error handling
                   print("Could not read. \(error), \(error.userInfo)")
               }
               
               // set note count
               self.count = returnedCategories.count
               
               return returnedCategories
    }
    
    static func readCategoriesFromCoreData(fromManagedObjectContext: NSManagedObjectContext, withPredicate: NSPredicate? = nil) -> [SlickCategory] {

        var returnedCategories = [SlickCategory]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        fetchRequest.predicate = withPredicate
        
        do {
            let fetchedCategoriesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            fetchedCategoriesFromCoreData.forEach { (fetchRequestResult) in
                let categoryManagedObjectRead = fetchRequestResult as! NSManagedObject
                returnedCategories.append(SlickCategory.init(categoryId: categoryManagedObjectRead.value(forKey: "categoryId") as! UUID, categoryName: categoryManagedObjectRead.value(forKey: "categoryName") as! String))
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not read. \(error), \(error.userInfo)")
        }
        
        
        return returnedCategories
    }
    
    static func readCatetgoryFromCoreData(
        categoryIdToBeRead:           UUID,
        fromManagedObjectContext: NSManagedObjectContext) -> SlickCategory? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        
        let categoryIdPredicate = NSPredicate(format: "categoryId = %@", categoryIdToBeRead as CVarArg)
        
        fetchRequest.predicate = categoryIdPredicate
        
        do {
            let fetchedCategoriesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let categoryManagedObjectToBeRead = fetchedCategoriesFromCoreData[0] as! NSManagedObject
           
            return SlickCategory.init(categoryId: categoryManagedObjectToBeRead.value(forKey: "categoryId") as! UUID, categoryName: categoryManagedObjectToBeRead.value(forKey: "categoryName") as!
                String)
        } catch let error as NSError {
            // TODO error handling
            print("Could not read. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    static func deleteCategoryFromCoreData(
        categoryIdToBeDeleted:        UUID,
        fromManagedObjectContext: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        
        let categoryIdAsCVarArg: CVarArg = categoryIdToBeDeleted as CVarArg
        let categoryIdPredicate = NSPredicate(format: "categoryId == %@", categoryIdAsCVarArg)
        
        fetchRequest.predicate = categoryIdPredicate
        
        do {
            let fetchedCategoriesFromCoreData = try fromManagedObjectContext.fetch(fetchRequest)
            let categoryManagedObjectToBeDeleted = fetchedCategoriesFromCoreData[0] as! NSManagedObject
            fromManagedObjectContext.delete(categoryManagedObjectToBeDeleted)
            
            do {
                try fromManagedObjectContext.save()
                self.count -= 1
            } catch let error as NSError {
                // TODO error handling
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            // TODO error handling
            print("Could not delete. \(error), \(error.userInfo)")
        }
        
    }
}
