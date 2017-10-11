//
//  RxCommand.swift
//  Driver
//
//  Created by Listen on 2017/10/7.
//  Copyright © 2017年 顺道嘉. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class RxCommand<Input, Output> {
    
    let block: (Input?) -> Observable<Output>
    
    private let addedExecutionObservableSubject = PublishSubject<Observable<Output>>()
    private let immediateEnabled = Variable(true)
    
    public let allowsConcurrent = Variable(false)
    public let executions: Observable<Observable<Output>>
    public let errors: Observable<Swift.Error>
    public let executing: Observable<Bool>
    public let enabled: Observable<Bool>

    public let disposeBag = DisposeBag()
    
    public init(enabled: Observable<Bool> = Observable.just(true), block: @escaping(Input?) -> Observable<Output>) {
        self.block = block
      
        executions = addedExecutionObservableSubject
            .map{ $0.catchError{ _ in Observable.empty() } }
            .observeOn(MainScheduler.instance)
        
        errors = addedExecutionObservableSubject
            .map {
                $0
                    .materialize()
                    .filter{ $0.error != nil }
                    .map{ $0.error! }
            }
            .switchLatest()
            .observeOn(MainScheduler.instance)
            .share()
        
        let immediateExecuting: Observable<Bool> = addedExecutionObservableSubject
            .flatMap {
                $0
                    .map { _ in 0 }
                    .ignoreElements()
                    .catchError{ _ in Observable.empty() }
                    .concat(Observable.just(-1))
                    .startWith(1)
            }
            .scan(0) { $0 + $1 }
            .map { $0 > 0 }
            .startWith(false)
        
        executing = immediateExecuting
            .observeOn(MainScheduler.instance)
            .startWith(false)
            .distinctUntilChanged()
            .shareReplay(1)
        
        Observable
            .combineLatest(allowsConcurrent.asObservable(), immediateExecuting, enabled) { ($0 || !$1) && $2 }
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .bind(to: immediateEnabled)
            .disposed(by: disposeBag)
        
        self.enabled = immediateEnabled.asObservable()
    }
    
    public func switchLatest() -> Observable<Output> {
        return executions.switchLatest().observeOn(MainScheduler.instance)
    }
    
    @discardableResult
    public func execute(_ input: Input? = nil) -> Observable<Output> {
        guard immediateEnabled.value else {
            return Observable.empty()
        }
        let observable = block(input)
        let connection = observable
            .subscribeOn(MainScheduler.instance)
            .publish()
        addedExecutionObservableSubject.onNext(connection)
        connection.connect().disposed(by: disposeBag)
        return connection
    }
}

extension ControlPropertyType {
    
    public func bind<Output>(to command: RxCommand<Self.E , Output>) -> Disposable {
        
        command.allowsConcurrent.value = true
        
        return subscribe { event in
            switch event {
            case let .next(element):
                command.execute(element)
            case let .error(error):
                let error = "Binding error to command: \(error)"
                #if DEBUG
                    fatalError(error)
                #else
                    print(error)
                #endif
            case .completed:
                break
            }
        }
    }
}

extension Reactive where Base: UIButton {
    public var command: CommandEvent {
        return CommandEvent(events:tap.asObservable(), enableObserver: isEnabled.asObserver())
    }
}

extension Reactive where Base: UIBarButtonItem {
    public var command: CommandEvent {
        return CommandEvent(events:tap.asObservable(), enableObserver: isEnabled.asObserver())
    }
}

public protocol CommandEventType: ObservableType {
    
}

public struct CommandEvent: CommandEventType {
    
    public typealias E = Void

    let events: Observable<Void>
    let enableObserver: AnyObserver<Bool>
    
    public init(events: Observable<Void>, enableObserver: AnyObserver<Bool>) {
        self.events = events
        self.enableObserver = enableObserver
    }
    
    public func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return events.subscribe(observer)
    }
    
    public func bind<Output>(to command: RxCommand<Void, Output>) -> Disposable {
        
        command
            .enabled
            .bind(to: enableObserver)
            .disposed(by: command.disposeBag)

        return subscribe { e in
            switch e {
            case let .next(element):
                command.execute(element)
            case let .error(error):
                let error = "Binding error to command: \(error)"
                #if DEBUG
                    fatalError(error)
                #else
                    print(error)
                #endif
            case .completed:
                break
            }
        }
    }
}
