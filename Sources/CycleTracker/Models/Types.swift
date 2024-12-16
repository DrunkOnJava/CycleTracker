import Foundation

enum CompoundType: String, Codable, CaseIterable {
    case testosterone
    case nandrolone
    case trenbolone
    case boldenone
    case stanozolol
    case other
}

enum InjectionSite: String, Codable, CaseIterable {
    case gluteus
    case quadriceps
    case deltoid
    case ventroGluteal
    case triceps
    case other
}
