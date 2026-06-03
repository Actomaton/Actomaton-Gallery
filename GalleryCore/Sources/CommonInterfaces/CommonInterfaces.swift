@_exported import ActomatonUI

// Pin `Emission` to `Never` so call sites can keep the shorter `Effect<Action>` /
// `Reducer<Action, State, Environment>` spellings (no `, Never`) after Actomaton
// gained the `Emission` generic parameter (see Actomaton PR #146/#147).
//
// `CommonInterfaces` is the single re-export shim: importing it brings the full
// `ActomatonUI` API plus these `Never`-pinned aliases. A file's own `import` wins
// over a module-wide re-export, so files that want the alias must import
// `CommonInterfaces` *instead of* `ActomatonUI`.
public typealias Effect<Action> = ActomatonEffect.Effect<Action, Never>
public typealias Reducer<Action, State, Environment> = MealyReducer<Action, State, Environment, ActomatonEffect.Effect<Action, Never>>
