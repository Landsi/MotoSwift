import Foundation
import Spectre
import CoreData

func testGeneratedCode() {
   describe("TypesModel") {
      $0.it("maps non scalar attributes") {
         let context = try createContext()
         let types = NSEntityDescription.insertNewObject(forEntityName: AllTypesClass.entityName, into: context) as! AllTypesClass
         types.int16 = 16
         types.int32 = 32
         types.int64 = 64
         types.boolean = false
         types.decimal = NSDecimalNumber(value: 100)
         types.float = 1.2
         types.double = 3.4
         types.string = "all types"
         let now = NSDate()
         types.date = now

         let scalarTypes = NSEntityDescription.insertNewObject(forEntityName: "ScalarTypes", into: context) as! ScalarTypesClass
         scalarTypes.boolean = true
         types.scalars = scalarTypes

         try context.save()
         try expect(types.int16) == 16
         try expect(types.int32) == 32
         try expect(types.int64) == 64
         try expect(types.boolean!.boolValue).to.beFalse()
         try expect(types.decimal) == NSDecimalNumber(value: 100)
         try expect(types.float!.floatValue).to.beClose(to: 1.2)
         try expect(types.double!.doubleValue).to.beClose(to: 3.4)
         try expect(types.string) == "all types"
         try expect(types.date) == now
      }

      $0.it("maps scalar attributes") {
         let context = try createContext()
         let scalarTypes = NSEntityDescription.insertNewObject(forEntityName: ScalarTypesClass.entityName, into: context) as! ScalarTypesClass
         let numericTypes = NSEntityDescription.insertNewObject(forEntityName: NumericTypesClass.entityName, into: context) as! NumericTypesClass
         numericTypes.boolean = true
         scalarTypes.numerics = numericTypes
         scalarTypes.int16 = 2
         scalarTypes.int32 = 4
         scalarTypes.int64 = 8
         scalarTypes.boolean = false
         scalarTypes.float = 5.6
         scalarTypes.double = 7.8
         try context.save()
         try expect(scalarTypes.int16) == 2
         try expect(scalarTypes.int32) == 4
         try expect(scalarTypes.int64) == 8
         try expect(scalarTypes.boolean) == false
         try expect(scalarTypes.float).to.beClose(to: 5.6)
         try expect(scalarTypes.double).to.beClose(to: 7.8)
      }

      $0.it("generates names") {

         let context = try createContext()
         let scalarTypes = NSEntityDescription.insertNewObject(forEntityName: CoreDataEntity.ScalarTypes.name, into: context)
         let allTypes = NSEntityDescription.insertNewObject(forEntityName: CoreDataEntity.AllTypes.name, into: context)

         scalarTypes.setValue(allTypes, forKey: CoreDataEntity.ScalarTypes.Field.numerics)
         scalarTypes.setValue(2, forKey: CoreDataEntity.ScalarTypes.Field.int16)
         scalarTypes.setValue(4, forKey: CoreDataEntity.ScalarTypes.Field.int32)
         scalarTypes.setValue(8, forKey: CoreDataEntity.ScalarTypes.Field.int64)
         scalarTypes.setValue(false, forKey: CoreDataEntity.ScalarTypes.Field.boolean)
         scalarTypes.setValue(5.6, forKey: CoreDataEntity.ScalarTypes.Field.float)
         scalarTypes.setValue(7.8, forKey: CoreDataEntity.ScalarTypes.Field.double)
         allTypes.setValue(9.1, forKey: CoreDataEntity.AllTypes.Field.double)
         try context.save()
         try expect(scalarTypes.value(forKey: CoreDataEntity.ScalarTypes.Field.int16) as? Int) == 2
         try expect(scalarTypes.value(forKey: CoreDataEntity.ScalarTypes.Field.int32) as? Int) == 4
         try expect(scalarTypes.value(forKey: CoreDataEntity.ScalarTypes.Field.int64) as? Int) == 8
         try expect(scalarTypes.value(forKey: CoreDataEntity.ScalarTypes.Field.boolean) as? Bool) == false
         try expect(scalarTypes.value(forKey: CoreDataEntity.ScalarTypes.Field.float) as? Float).to.beClose(to: 5.6)
         try expect(scalarTypes.value(forKey: CoreDataEntity.ScalarTypes.Field.double) as? Double).to.beClose(to: 7.8)
         try expect(allTypes.value(forKey: CoreDataEntity.AllTypes.Field.double) as? Double).to.beClose(to: 9.1)
      }
   }
}

private func createContext() throws -> NSManagedObjectContext {
   let modelUrl = url(forResource: "TypesModel", ofType: "momd")
   let model = NSManagedObjectModel(contentsOf: modelUrl)!
   let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
   try coordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                      configurationName: nil,
                                      at: nil,
                                      options: nil)
   let context = NSManagedObjectContext()
   context.persistentStoreCoordinator = coordinator
   return context
}
