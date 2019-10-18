//
//  RealmService.swift
//  timer
//
//  Created by JSilver on 04/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import RxSwift
import RealmSwift

class RealmService: BaseService, DatabaseServiceProtocol {
    // MARK: - time set operate
    /// Fetch all time set list
    /// - returns: A observable that emit all time set info list
    func fetchTimeSets() -> Single<[TimeSetInfo]> {
        return fetch()
    }
    
    /// Create a time set
    /// - parameters:
    ///   - info: data of the time set
    /// - returns: A observable that emit a created time set info
    func createTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        return create(info)
    }
    
    /// Remove the time set
    /// - parameters:
    ///   - id: Identifier of the time set to remove
    /// - returns: A observable that emit a removed time set info
    func removeTimeSet(id: String) -> Single<TimeSetInfo> {
        return remove(key: id)
    }
    
    /// Remove time set list
    /// - parameters:
    ///   - ids: Identifier list of the time set list to remove
    /// - returns: A observable that emit all removed time set info list
    func removeTimeSets(ids: [String]) -> Single<[TimeSetInfo]> {
        return remove(keys: ids)
    }
    
    /// Update the time set
    /// - parameters:
    ///   - info: data of the time set
    /// - returns: A observable that emit a updated time set info
    func updateTimeSet(info: TimeSetInfo) -> Single<TimeSetInfo> {
        return update(info)
    }
    
    /// Update time set list
    /// - parameters:
    ///   - infoes: data list of the time set
    /// - returns: A observable that emit all updated time set info list
    func updateTimeSets(infoes: [TimeSetInfo]) -> Single<[TimeSetInfo]> {
        return update(list: infoes)
    }
    
    /// Fetch all hisotry list
    /// - returns: A observable that emit all history list
    func fetchHistories() -> Single<[History]> {
        return fetch()
    }
    
    /// Create a history
    /// - parameters:
    ///   - history: data of the history
    /// - returns: A observable that emit a created history
    func createHistory(_ history: History) -> Single<History> {
        guard history.id > 0 else { return .error(DatabaseError.wrongData) }
        return create(history)
    }
    
    /// Update the history
    /// - parameters:
    ///   - history: data of the history
    /// - returns: A observable that emit a updated hisotry
    func updateHistory(_ history: History) -> Single<History> {
        guard history.id > 0 else { return .error(DatabaseError.wrongData) }
        return update(history)
    }
    
    // MARK: - database operate
    /// Clear all data from database
    func clear() {
        guard let realm = try? Realm() else { return }
        try? realm.write {
            realm.deleteAll()
        }
    }
    
    // MARK: - private method
    /// Fetch object list from `realm`
    /// - returns: `Single` observable wrap created object list, not realm object (copied)
    private func fetch<T>() -> Single<[T]> where T: Object & NSCopying {
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use realm.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    do {
                        // Open `Realm`
                        let realm = try self.open()

                        // Transaction
                        let objects = realm.objects(T.self)
                        Logger.info("fetch objects from realm - count(\(objects.count)) \n\(objects)", tag: "REALM")
                        
                        // Copy time set from realm object & Emit copied object
                        let copiedObjects = objects.toArray().compactMap { $0.copy() as? T }
                        emitter(.success(copiedObjects))
                    } catch {
                        emitter(.error(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Create realm object from passed parameter type T inherited `Object`
    /// - parameters:
    ///   - object: object that will create to `realm`
    /// - returns: `Single` observable wrap created object, not realm object (copied)
    private func create<T>(_ object: T) -> Single<T> where T: Object & NSCopying {
        // Copy data to preserve original object
        guard let object = object.copy() as? T else { return .error(DatabaseError.unknown) }
        
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use `Realm`.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    do {
                        // Open `Realm`
                        let realm = try self.open()
                        
                        // Transaction
                        try self.write(realm) {
                            realm.add(object)
                        }
                        Logger.info("created object and save into realm \n\(object)", tag: "REALM")
                        
                        // Copy time set from realm object & Emit copied object
                        guard let copiedObject = object.copy() as? T else { throw DatabaseError.unknown }
                        emitter(.success(copiedObject))
                    } catch {
                        emitter(.error(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Remove object from `ream` using key
    /// - parameters:
    ///   - key: Identifier of the object to remove
    /// - returns: `Single` observable wrap removed object, not realm object (copied)
    private func remove<T>(key: String) -> Single<T> where T: Object & NSCopying {
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use realm.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    do {
                        // Open `Realm`
                        let realm = try self.open()
                        
                        // Transaction
                        guard let object = realm.object(ofType: T.self, forPrimaryKey: key) else { throw DatabaseError.notFound }
                        
                        // Copy time set from realm object
                        guard let copiedObject = object.copy() as? T else { throw DatabaseError.unknown }
                        
                        try self.write(realm) {
                            realm.delete(object)
                        }
                        Logger.info("removed object from realm - key(\(key))", tag: "REALM")
                        
                        emitter(.success(copiedObject))
                    } catch {
                        emitter(.error(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Remove object list from `ream` using key list
    /// - parameters:
    ///   - keys: Identifier list of the object to remove
    /// - returns: `Single` observable wrap removed object list, not realm object (copied)
    private func remove<Key, T>(keys: [Key]) -> Single<[T]> where T: Object & NSCopying {
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use realm.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    do {
                        // Open `Realm`
                        let realm = try self.open()
                        
                        // Transaction
                        let objects = keys.compactMap { realm.object(ofType: T.self, forPrimaryKey: $0) }
                        
                        // Copy time set from realm object
                        let copiedObject = objects.compactMap({ $0.copy() as? T })
                        
                        try self.write(realm) {
                            realm.delete(objects)
                        }
                        Logger.info("removed objects from realm - count(\(objects.count)) \n\(objects)", tag: "REALM")
                        
                        emitter(.success(copiedObject))
                    } catch {
                        emitter(.error(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Update realm object from passed parameter type T inherited `Object`
    /// - parameters:
    ///   - object: object that will update to `realm`
    /// - returns: `Single` observable wrap updated object, not realm object (copied)
    private func update<T>(_ object: T) -> Single<T> where T: Object & NSCopying {
        // Copy data to preserve original object
        guard let object = object.copy() as? T else { return .error(DatabaseError.unknown) }
        
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use realm.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    do {
                        // Open `Realm`
                        let realm = try self.open()
                        
                        // Transaction
                        try self.write(realm, {
                            realm.add(object, update: .all)
                        })
                        Logger.info("updated object of realm \n\(object)", tag: "REALM")
                        
                        // Copy time set from realm object & Emit copied object
                        guard let copiedObject = object.copy() as? T else { throw DatabaseError.unknown }
                        emitter(.success(copiedObject))
                    } catch {
                        emitter(.error(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Update realm object from passed parameter type T inherited `Object`
    /// - parameters:
    ///   - objects: object list that will update to `realm`
    /// - returns: `Single` observable wrap updated object list, not realm object (copied)
    private func update<T>(list objects: [T]) -> Single<[T]> where T: Object & NSCopying {
        // Copy data to preserve original object
        let objects = objects.compactMap { $0.copy() as? T }
        
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use realm.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    do {
                        // Open `Realm`
                        let realm = try self.open()
                        
                        // Transaction
                        try self.write(realm) {
                            realm.add(objects, update: .all)
                        }
                        Logger.info("updated objects of - count(\(objects.count)) \n\(objects)", tag: "REALM")
                        
                        // Copy time set from realm object & Emit copied object
                        let copiedObjects = objects.compactMap({ $0.copy() as? T })
                        emitter(.success(copiedObjects))
                    } catch {
                        emitter(.error(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }

    /// Open realm database
    /// - returns: opened `Realm` object
    /// - throws: `DatabaseError.initialize` : if any error occured when create `realm` call `Realm()`
    private func open() throws -> Realm {
        do {
            return try Realm()
        } catch {
            Logger.error(error)
            throw DatabaseError.initialize
        }
    }
    
    /// Write object into `realm`
    /// - parameters:
    ///   - realm: `Realm` object to write
    ///   - block: transaction about realm I/O
    /// - throws: `DatabaseError.transaction` : if any error occured during `realm.write()` process
    private func write(_ realm: Realm, _ block: () -> Void) throws {
        do {
            try realm.write {
                block()
            }
        } catch {
            Logger.error(error)
            throw DatabaseError.transaction
        }
    }
}
