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
    func fetchTimeSet(id: Int) -> Single<TimeSetItem> {
        fetch(key: id)
    }
    
    func fetchTimeSets() -> Single<[TimeSetItem]> {
        fetch(filter: NSPredicate(format: "isSaved = true"))
    }
    
    func fetchRecentlyUsedTimeSets(count: Int) -> Single<[TimeSetItem]> {
        // Fetch recent history list that refer saved time set and distinct refering origin id
        let recentUsedHistories: Single<[History]> = fetch(
            filter: NSPredicate(format: "originId > 0"),
            sorted: SortingParam(keyPath: "startDate"),
            distinct: "originId",
            pagination: PaginationParam(count: count)
        )
        
        return recentUsedHistories.flatMap {
            // Fetch time set item list from id
            Single.zip(
                $0.map { $0.originId }
                    .map { id -> Single<TimeSetItem> in self.fetch(key: id) }
            )
        }
    }
    
    func createTimeSet(item: TimeSetItem) -> Single<TimeSetItem> {
        create(item)
    }
    
    func removeTimeSet(id: Int) -> Single<TimeSetItem> {
        remove(key: id)
    }
    
    func removeTimeSets(ids: [Int]) -> Single<[TimeSetItem]> {
        remove(keys: ids)
    }
    
    func updateTimeSet(item: TimeSetItem) -> Single<TimeSetItem> {
        update(item)
    }
    
    func updateTimeSets(items: [TimeSetItem]) -> Single<[TimeSetItem]> {
        update(list: items)
    }
    
    func fetchHistories(pagination: PaginationParam?) -> Single<[History]> {
        fetch(sorted: SortingParam(keyPath: "startDate"), pagination: pagination)
    }
    
    func fetchHistories(origin id: Int) -> Single<[History]> {
        fetch(filter: NSPredicate(format: "originId == %d", id))
    }
    
    func fetchHistories(origin ids: [Int]) -> Single<[History]> {
        fetch(filter: NSPredicate(format: "originId IN %@", ids))
    }
    
    func createHistory(_ history: History) -> Single<History> {
        guard history.id > 0 && history.originId > 0 else { return .error(DatabaseError.invalidFormat) }
        return create(history)
    }
    
    func updateHistory(_ history: History) -> Single<History> {
        update(history)
    }
    
    func updateHistories(_ histories: [History]) -> Single<[History]> {
        update(list: histories)
    }
    
    // MARK: - database operate
    func clear() {
        guard let realm = try? Realm() else { return }
        try? realm.write {
            realm.deleteAll()
        }
    }
    
    // MARK: - private method
    private func fetch<Key, T>(key: Key) -> Single<T> where T: Object {
        Single.create { emitter in
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
                        
                        // Copy object from realm object
                        guard let copiedObject = object.copy() as? T else { throw DatabaseError.unknown }
                        
                        Logger.info("fetch object from realm\n\(object)", tag: "REALM")
                        DispatchQueue.main.async {
                            emitter(.success(copiedObject))
                        }
                    } catch {
                        emitter(.error(error))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Fetch object list from `realm`
    /// - returns: `Single` observable wrap created object list, not realm object (copied)
    private func fetch<T>(
        filter: NSPredicate? = nil,
        sorted: SortingParam? = nil,
        distinct: String? = nil,
        pagination: PaginationParam? = nil
    ) -> Single<[T]> where T: Object & NSCopying {
        Single.create { emitter in
            // Realm transaction in global queue (background thread)
            DispatchQueue.global().async {
                // Wrap autorelease pool explicitly due to use realm.
                // Not occur problems normally even if not use autorelase pool. but `Realm` document recommended for efficiency
                autoreleasepool {
                    do {
                        // Open `Realm`
                        let realm = try self.open()

                        // Transaction
                        var objects = realm.objects(T.self)
                        if let filter = filter {
                            objects = objects.filter(filter)
                        }
                        if let sorted = sorted {
                            objects = objects.sorted(byKeyPath: sorted.keyPath, ascending: sorted.accending)
                        }
                        if let distinct = distinct {
                            objects = objects.distinct(by: [distinct])
                        }
                        
                        let result: [T]
                        if let pagination = pagination {
                            // Pagiate if pagination info isn't `nil`
                            result = objects.range(pagination.range)
                        } else {
                            result = objects.toArray()
                        }
                        
                        Logger.info("fetch objects from realm - count(\(result.count)) \n\(result)", tag: "REALM")
                        
                        // Copy time set from realm object & Emit copied object
                        let copiedObjects = result.compactMap { $0.copy() as? T }
                        DispatchQueue.main.async {
                            emitter(.success(copiedObjects))
                        }
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
                        DispatchQueue.main.async {
                            emitter(.success(copiedObject))
                        }
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
    private func remove<Key, T>(key: Key) -> Single<T> where T: Object & NSCopying {
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
                        DispatchQueue.main.async {
                            emitter(.success(copiedObject))
                        }
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
                        let copiedObjects = objects.compactMap({ $0.copy() as? T })
                        
                        try self.write(realm) {
                            realm.delete(objects)
                        }
                        Logger.info("removed objects from realm - count(\(objects.count)) \n\(objects)", tag: "REALM")
                        DispatchQueue.main.async {
                            emitter(.success(copiedObjects))
                        }
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
                        DispatchQueue.main.async {
                            emitter(.success(copiedObject))
                        }
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
                        DispatchQueue.main.async {
                            emitter(.success(copiedObjects))
                        }
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
