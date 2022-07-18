import SwiftUI
import ActomatonUI
import VectorMath

struct SpringExample: Example
{
    var exampleIcon: Image { Image(systemName: "tornado") }

    var exampleInitialState: PhysicsRoot.State.Current
    {
        .spring(World.State(objects: CircleObject.orbitingObjects))
    }

    var exampleArrowScale: ArrowScale
    {
        .init(velocityArrowScale: 10, forceArrowScale: 300)
    }

    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>) -> AnyView
    {
        let configuration = store.viewStore.configuration

        return Self.exampleView(
            store: store,
            action: PhysicsRoot.Action.spring,
            statePath: /PhysicsRoot.State.Current.spring,
            makeView: {
                WorldView(
                    store: $0,
                    configuration: configuration,
                    absolutePosition: self.absolutePosition,
                    arrowScale: self.exampleArrowScale
                )
            }
        )
    }
}

// MARK: - Algorithm

extension SpringExample: ObjectWorldExample
{
    func step(objects: inout [CircleObject], boardSize: CGSize)
    {
        let objectCount = objects.count

        guard objectCount >= 2 else { return }

        let firstObj = objects.first!

        for i in 1 ..< objectCount {
            let other = objects[i] // non-firstObj

            let posDiff = other.position - firstObj.position
            let length = posDiff.length

            /// Force between `other` and `firstObj`.
            /// F = -k * position - damping * velocity
            let force = -posDiff.normalized() * c.k * (length - c.springLength) - other.velocity * c.damping
            objects[i].force = force

            // Simulates spring lattice between `other`s.
            if isSpringLatticeEnabled && objectCount > 2 {
                for j in 2 ..< objectCount {
                    if i == j && i == objectCount - 1 { break }

                    let other2 = objects[j] // non-firstObj, non-other

                    let posDiff = other.position - other2.position
                    let length = posDiff.length

                    /// Force between `other` and `other2`.
                    /// F = -k * position - damping * velocity
                    let force = -posDiff.normalized() * c2.k * (length - c2.springLength)
                        - (other.velocity - other2.velocity) * c2.damping
                    objects[i].force = objects[i].force + force
                    objects[j].force = objects[j].force - force // action-reaction law
                }
            }
        }
    }
}

// MARK: - Types

private struct Constants
{
    /// Simulated spring constant.
    let k: Scalar

    /// Simulated spring dumping constant.
    let damping: Scalar

    /// Simulated spring's natural length.
    let springLength: Scalar
}

// MARK: - Constants

/// Simulated spring constants between 1st obj and other object.
private let c: Constants = .init(k: 0.005, damping: 0.01, springLength: 60)

/// Simulated spring constants between non-1st objects.
private let c2: Constants = .init(k: 0.0005, damping: 0.01, springLength: 150)

private let isSpringLatticeEnabled: Bool = false
