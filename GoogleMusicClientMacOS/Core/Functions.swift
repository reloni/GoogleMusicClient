//
//  Functions.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 31/10/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

typealias MutableSetter<S, A> = (@escaping (inout A) -> Void) -> (inout S) -> Void

func mutate<S, A>(
    _ setter: MutableSetter<S, A>,
    _ set: @escaping (inout A) -> Void
    )
    -> (inout S) -> Void {
        return setter(set)
}

func mutate<S, A>(
    _ setter: MutableSetter<S, A>,
    _ value: A
    )
    -> (inout S) -> Void {
        return mutate(setter) { $0 = value }
}

prefix operator ^
prefix func ^ <Root, Value>(
    _ kp: WritableKeyPath<Root, Value>
    )
    -> (@escaping (inout Value) -> Void)
    -> (inout Root) -> Void {
        
        return { update in
            { root in
                update(&root[keyPath: kp])
            }
        }
}

func |> <A, B>(a: A, f: @escaping (A) -> B) -> B {
    return f(a)
}

func |> <A>(_ a: A, _ f: (inout A) -> Void) -> A {
    var a = a
    f(&a)
    return a
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

func <> <A>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> (inout A) -> Void {
    return { value in
        f(&value)
        g(&value)
    }
}
func <> <A>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> ((A) -> A) {
    return f >>> g
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
