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
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use `Realm`.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    // Create `Realm`
                    guard let realm = try? Realm() else {
                        emitter(.error(DatabaseError.initialize))
                        return
                    }
                    
                    // Transaction
                    do {
                        try realm.write {
                            realm.add(info)
                        }
                    } catch {
                        emitter(.error(DatabaseError.transaction))
                    }
                    Logger.info("created objects \n\(info)", tag: "REALM")
                    
                    // Pass data through main dispatch queue
                    let threadSafeObject = ThreadSafeReference(to: info)
                    DispatchQueue.main.async {
                        // Create `Realm` in main thread and resolve passed object
                        guard let realm = try? Realm(),
                            let resolvedObject = realm.resolve(threadSafeObject) else {
                            emitter(.error(DatabaseError.initialize))
                            return
                        }
                        emitter(.success(resolvedObject))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Remove the time set
    /// - parameters:
    ///   - id: Identifier of the time set to remove
    /// - returns: A observable that emit a removed time set info
    func removeTimeSet(id: String) -> Single<TimeSetInfo> {
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use realm.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    // Create `Realm`
                    guard let realm = try? Realm() else {
                        emitter(.error(DatabaseError.initialize))
                        return
                    }
                    
                    // Transaction
                    guard let timeSet = realm.object(ofType: TimeSetInfo.self, forPrimaryKey: id) else {
                        emitter(.error(DatabaseError.notFound))
                        return
                    }
                    
                    do {
                        try realm.write {
                            realm.delete(timeSet)
                        }
                    } catch {
                        emitter(.error(DatabaseError.transaction))
                    }
                    Logger.info("removed objects \n\(timeSet)", tag: "REALM")
                    
                    // Pass data through main dispatch queue
                    let threadSafeObject = ThreadSafeReference(to: timeSet)
                    DispatchQueue.main.async {
                        // Create `Realm` in main thread and resolve passed object
                        guard let realm = try? Realm(),
                            let resolvedObject = realm.resolve(threadSafeObject) else {
                            emitter(.error(DatabaseError.initialize))
                            return
                        }
                        
                        emitter(.success(resolvedObject))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Update the time set
    /// - parameters:
    ///   - id: Identifier of the time set to update
    ///   - info: data of the time set
    /// - returns: A observable that emit a updated time set info
    func updateTimeSet(id: String, info: TimeSetInfo) -> Single<TimeSetInfo> {
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use realm.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    // Create `Realm`
                    guard let realm = try? Realm() else {
                        emitter(.error(DatabaseError.initialize))
                        return
                    }
                    
                    // Transaction
                    do {
                        try realm.write {
                            realm.add(info, update: .all)
                        }
                    } catch {
                        emitter(.error(DatabaseError.transaction))
                    }
                    Logger.info("updated objects \n\(info)", tag: "REALM")
                    
                    // Pass data through main dispatch queue
                    let threadSafeObject = ThreadSafeReference(to: info)
                    DispatchQueue.main.async {
                        // Create `Realm` in main thread and resolve passed object
                        guard let realm = try? Realm(),
                            let resolvedObject = realm.resolve(threadSafeObject) else {
                            emitter(.error(DatabaseError.initialize))
                            return
                        }
                        emitter(.success(resolvedObject))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: - database operate
    func clear() {
        guard let realm = try? Realm() else { return }
        try? realm.write {
            realm.deleteAll()
        }
    }
    
    // MARK: - private method
    func fetch<T>() -> Single<[T]> where T: Object {
        return Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use realm.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    // Create `Realm`
                    guard let realm = try? Realm() else {
                        emitter(.error(DatabaseError.initialize))
                        return
                    }
                    
                    // Transaction
                    let objects = realm.objects(T.self)
                    Logger.info("fetch objects - (\(objects.count)) \n\(objects)", tag: "REALM")
                    
                    // Pass data through main dispatch queue
                    let threadSafeObjects = ThreadSafeReference(to: objects)
                    DispatchQueue.main.async {
                        // Create `Realm` in main thread and resolve passed object
                        guard let realm = try? Realm(),
                            let resolvedObjects = realm.resolve(threadSafeObjects) else {
                                emitter(.error(DatabaseError.initialize))
                                return
                        }
                        
                        emitter(.success(resolvedObjects.toArray()))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}
