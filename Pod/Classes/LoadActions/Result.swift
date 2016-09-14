//
//  Result.swift
//  Pods
//
//  Created by Gabriel Lanata on 9/9/16.
//
//

import Foundation

public enum Result<T> {
    case success(T), failure(Error)
    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    public var isFailure: Bool {
        switch self {
        case .success: return false
        case .failure: return true
        }
    }
    public var value: T? {
        switch self {
        case .success(let value): return value
        case .failure(_): return nil
        }
    }
    public var error: Error? {
        switch self {
        case .success(_): return nil
        case .failure(let error): return error
        }
    }
}

public extension Result {
    
    // Return the value if it's a .Success or throw the error if it's a .Failure
    public func resolve() throws -> T {
        switch self {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
    
    // Construct a .Success if the expression returns a value or a .Failure if it throws
    public init(_ throwingExpr: (Void) throws -> T) {
        do {
            let value = try throwingExpr()
            self = .success(value)
        } catch(let error) {
            self = .failure(error)
        }
    }
    
}

public extension Result {
    
    public func map<U>(_ f: (T)->U) -> Result<U> {
        switch self {
        case .success(let t): return .success(f(t))
        case .failure(let err): return .failure(err)
        }
    }
    
    public func flatMap<U>(_ f: (T)->Result<U>) -> Result<U> {
        switch self {
        case .success(let t): return f(t)
        case .failure(let err): return .failure(err)
        }
    }
    
}

extension Result: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
        case .success:
            return "Result(SUCCESS)"
        case .failure:
            return "Result(FAILURE)"
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .success(let value):
            return "Result(SUCCESS): \(value)"
        case .failure(let error):
            return "Result(FAILURE): \(error)"
        }
    }
    
}
