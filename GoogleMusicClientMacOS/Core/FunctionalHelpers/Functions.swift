//
//  Functions.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 31/10/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

func |> <A, B>(a: A, f: @escaping (A) -> B) -> B {
    return f(a)
}

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { input in
        return g(f(input))
    }
}

func <<< <A, B, C>(g: @escaping (B) -> C, f: @escaping (A) -> B) -> (A) -> C {
    return { x in
        g(f(x))
    }
}

func <> <A>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
    return { value in
        f(value)
        g(value)
    }
}
func <> <A>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> ((A) -> A) {
    return f >>> g
}

func .~ <Object, Value>(_ kp: WritableKeyPath<Object, Value>, _ v: Value) -> (Object) -> Object {
    return (property(kp)) { _ in v }
}

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in
        return { b in
            return f(a, b)
        }
    }
}

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in
        return { a in
            return f(a)(b)
        }
    }
}

func property<Object, Value> (_ kp: WritableKeyPath<Object, Value>) -> (@escaping (Value) -> Value) -> (Object) -> Object {
    return { value in
        return { object in
            var copy = object
            copy[keyPath: kp] = value(copy[keyPath: kp])
            return copy
        }
    }
}

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
    return { $0.map(f) }
}

func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
    return { $0.map(f) }
}
