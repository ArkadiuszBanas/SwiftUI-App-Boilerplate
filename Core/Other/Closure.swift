//
//  Closure.swift
//  SwiftUI-App-Boilerplate
//
//  Created by Arek on 24/05/2022.
//

import Foundation

// MARK: - Generic

public typealias ReturnClosure<T> = () -> T
public typealias ThrowableReturnClosure<T> = () throws -> T
public typealias ValueClosure<T> = ValueReturnClosure<T, Void>
public typealias ValueReturnClosure<T, R> = (_ value: T) -> R
public typealias ValueThrowableReturnClosure<T, R> = (_ value: T) throws -> R
public typealias VoidClosure = ReturnClosure<Void>
public typealias VoidThrowableClosure = ThrowableReturnClosure<Void>

// MARK: - Networking

public typealias Handler<T, E: Error> = ValueClosure<Result<T, E>>
public typealias EmptyHandler<E: Error> = ValueClosure<Result<Void, E>>
public typealias NetworkHandler<T> = ValueClosure<Result<T, Error>>
public typealias EmptyNetworkHandler = NetworkHandler<Void>
