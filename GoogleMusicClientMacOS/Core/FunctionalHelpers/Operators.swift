//
//  Operators.swift
//  RxGoogleMusic
//
//  Created by Anton Efimenko on 31/10/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |>: ForwardApplication

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}
infix operator >>>: ForwardComposition

infix operator .~: ForwardComposition

precedencegroup SingleComposition {
    associativity: left
    higherThan: ForwardApplication, ForwardComposition
}
infix operator <>: SingleComposition

precedencegroup BackwardsComposition {
    associativity: right
    higherThan: ForwardApplication
}
infix operator <<<: BackwardsComposition


