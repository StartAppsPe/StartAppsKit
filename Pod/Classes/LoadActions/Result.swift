//
//  Result.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/9/16.
//
//

import Foundation

public enum Result<T> {
    case Success(T), Failure(ErrorType)
    public var isSuccess: Bool {
        switch self {
        case .Success: return true
        case .Failure: return false
        }
    }
    public var isFailure: Bool {
        switch self {
        case .Success: return false
        case .Failure: return true
        }
    }
    public var value: T? {
        switch self {
        case .Success(let value): return value
        case .Failure(_): return nil
        }
    }
    public var error: ErrorType? {
        switch self {
        case .Success(_): return nil
        case .Failure(let error): return error
        }
    }
}

public extension Result {
    
    // Return the value if it's a .Success or throw the error if it's a .Failure
    public func resolve() throws -> T {
        switch self {
        case .Success(let value): return value
        case .Failure(let error): throw error
        }
    }
    
    // Construct a .Success if the expression returns a value or a .Failure if it throws
    public init(@noescape _ throwingExpr: Void throws -> T) {
        do {
            let value = try throwingExpr()
            self = .Success(value)
        } catch(let error) {
            self = .Failure(error)
        }
    }
    
}

public extension Result {
    
    public func map<U>(f: T->U) -> Result<U> {
        switch self {
        case .Success(let t): return .Success(f(t))
        case .Failure(let err): return .Failure(err)
        }
    }
    
    public func flatMap<U>(f: T->Result<U>) -> Result<U> {
        switch self {
        case .Success(let t): return f(t)
        case .Failure(let err): return .Failure(err)
        }
    }
    
}

extension Result: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
        case .Success:
            return "Result(SUCCESS)"
        case .Failure:
            return "Result(FAILURE)"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .Success(let value):
            return "Result(SUCCESS): \(value)"
        case .Failure(let error):
            return "Result(FAILURE): \(error)"
        }
    }
    
}