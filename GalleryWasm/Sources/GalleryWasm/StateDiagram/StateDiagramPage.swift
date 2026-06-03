import ElementaryUI
import JavaScriptKit

@View
struct StateDiagramPage
{
    private static let hostID = "sd-graph-host"
    private static let svgID = "sd-graph"

    @State var machine: StateDiagramDemoMachine

    init()
    {
        _machine = State(wrappedValue: makeStateDiagramDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "StateDiagram" }
            h2(.class("counter-heading")) { "Login Flow State Machine" }
            p(.class("counter-copy")) {
                "A login flow rendered as a live state graph. Each transition runs an async effect "
                "(Task.sleep) through the shared StateDiagram reducer on the browser event loop — "
                "watch the focus glide onto the current node while the transitions it can take light up."
            }

            div(.class("sd-stage")) {
                p(.class("sd-status \(statusClass)")) {
                    span(.class("sd-status-dot")) { "" }
                    span(.class("sd-status-text")) { "Current state" }
                    span(.class("sd-status-name")) { stateTitle }
                }

                // SVG graph host. The graph is built imperatively via JavaScriptKit (the SVG namespace is
                // unreachable through ElementaryUI's `createElement`); the host keeps constant content so the
                // reconciler never clears the appended `<svg>`. State changes only flip one `data-state`
                // attribute — all node / edge / focus styling is then driven declaratively from CSS.
                div(.class("sd-graph-host"), .custom(name: "id", value: Self.hostID)) { "" }
                    .onAppear {
                        buildStateDiagramGraph(hostID: Self.hostID, svgID: Self.svgID, initialState: stateName)
                    }
                    .onChange(of: machine.state.stateDiagram) {
                        setStateDiagramActiveState(svgID: Self.svgID, state: stateName)
                    }
            }

            div(.class("diagram-actions")) {
                button(.type(.button), .class("counter-action is-primary")) { "Login" }
                    .onClick { _ in machine.send(.login) }

                button(.type(.button), .class("counter-action")) { "Logout" }
                    .onClick { _ in machine.send(.logout) }

                button(.type(.button), .class("counter-action")) { "Force Logout" }
                    .onClick { _ in machine.send(.forceLogout) }
            }
        }
    }

    // MARK: - State-derived view data

    /// Lowercase identifier mirrored into the `<svg data-state>` attribute (the CSS hook).
    private var stateName: String
    {
        switch machine.state.stateDiagram {
        case .loggedOut:    return "loggedOut"
        case .loggingIn:    return "loggingIn"
        case .loggedIn:     return "loggedIn"
        case .loggingOut:   return "loggingOut"
        }
    }

    private var stateTitle: String
    {
        switch machine.state.stateDiagram {
        case .loggedOut:    return "Logged Out"
        case .loggingIn:    return "Logging In…"
        case .loggedIn:     return "Logged In"
        case .loggingOut:   return "Logging Out…"
        }
    }

    /// Per-state modifier class carrying the accent colour for the status pill.
    private var statusClass: String
    {
        switch machine.state.stateDiagram {
        case .loggedOut:    return "is-loggedOut"
        case .loggingIn:    return "is-loggingIn"
        case .loggedIn:     return "is-loggedIn"
        case .loggingOut:   return "is-loggingOut"
        }
    }
}

// MARK: - Imperative SVG construction (JavaScriptKit)

/// Builds the static login-flow graph once and appends it to the host element.
/// The current state is baked in as `data-state`; subsequent updates go through `setStateDiagramActiveState`.
private func buildStateDiagramGraph(hostID: String, svgID: String, initialState: String)
{
    guard let document = JSObject.global.document.object,
        let host = document.getElementById?(hostID).object
    else {
        return
    }

    // Guard against a second mount: if the graph already exists, just refresh the active state.
    if host.firstElementChild.object != nil {
        setStateDiagramActiveState(svgID: svgID, state: initialState)
        return
    }

    let svgNS = "http://www.w3.org/2000/svg"
    guard let svg = document.createElementNS?(svgNS, "svg").object else { return }

    _ = svg.setAttribute?("viewBox", "0 0 520 360")
    _ = svg.setAttribute?("class", "sd-svg")
    _ = svg.setAttribute?("id", svgID)
    _ = svg.setAttribute?("data-state", initialState)
    // The host SVG is already in the SVG namespace, so its innerHTML parses children as SVG too.
    svg.innerHTML = .string(stateDiagramInnerSVG)

    _ = host.appendChild?(svg)
}

/// Flips the single `data-state` attribute that all node / edge / focus CSS keys off of.
private func setStateDiagramActiveState(svgID: String, state: String)
{
    guard let svg = JSObject.global.document.object?.getElementById?(svgID).object else { return }
    _ = svg.setAttribute?("data-state", state)
}

/// The static graph markup: arrowhead marker, six labelled transition edges, the travelling focus ring,
/// and the four state nodes (settled states get a double outline, transient states a single one).
private let stateDiagramInnerSVG: String = """
<defs>
  <marker id="sd-arrow" viewBox="0 0 10 10" refX="8.5" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
    <path d="M0.5,0.5 L9.5,5 L0.5,9.5 Z" fill="context-stroke"/>
  </marker>
</defs>

<g class="sd-edges">
  <g class="sd-edge" data-from="loggedOut" style="--accent:#4f6b9a">
    <path class="sd-edge-path" d="M128,158 L210,88" marker-end="url(#sd-arrow)"/>
    <text class="sd-edge-label" x="150" y="116">Login</text>
  </g>
  <g class="sd-edge" data-from="loggingIn" style="--accent:#c67b1e">
    <path class="sd-edge-path" d="M310,88 L388,158" marker-end="url(#sd-arrow)"/>
    <text class="sd-edge-label" x="372" y="116">LoginOK</text>
  </g>
  <g class="sd-edge" data-from="loggingIn" style="--accent:#c67b1e">
    <path class="sd-edge-path" d="M260,92 L260,266" marker-end="url(#sd-arrow)"/>
    <text class="sd-edge-label" x="306" y="176">ForceLogout</text>
  </g>
  <g class="sd-edge" data-from="loggedIn" style="--accent:#2f7d52">
    <path class="sd-edge-path" d="M388,202 L322,268" marker-end="url(#sd-arrow)"/>
    <text class="sd-edge-label" x="394" y="234">Logout</text>
  </g>
  <g class="sd-edge" data-from="loggedIn" style="--accent:#2f7d52">
    <path class="sd-edge-path" d="M420,206 Q472,302 328,300" marker-end="url(#sd-arrow)"/>
    <text class="sd-edge-label" x="450" y="252">ForceLogout</text>
  </g>
  <g class="sd-edge" data-from="loggingOut" style="--accent:#7d5ba6">
    <path class="sd-edge-path" d="M200,270 L124,204" marker-end="url(#sd-arrow)"/>
    <text class="sd-edge-label" x="150" y="256">LogoutOK</text>
  </g>
</g>

<rect class="sd-focus" x="0" y="0" width="152" height="72" rx="36"/>

<g class="sd-nodes">
  <g id="sd-node-loggingIn" class="sd-node sd-node--transient" style="--accent:#c67b1e">
    <rect class="sd-node-pill" x="194" y="38" width="132" height="52" rx="26"/>
    <text class="sd-node-label" x="260" y="64">Logging In…</text>
  </g>
  <g id="sd-node-loggedOut" class="sd-node sd-node--settled" style="--accent:#4f6b9a">
    <rect class="sd-node-ring" x="9" y="149" width="142" height="62" rx="31"/>
    <rect class="sd-node-pill" x="14" y="154" width="132" height="52" rx="26"/>
    <text class="sd-node-label" x="80" y="180">Logged Out</text>
  </g>
  <g id="sd-node-loggedIn" class="sd-node sd-node--settled" style="--accent:#2f7d52">
    <rect class="sd-node-ring" x="369" y="149" width="142" height="62" rx="31"/>
    <rect class="sd-node-pill" x="374" y="154" width="132" height="52" rx="26"/>
    <text class="sd-node-label" x="440" y="180">Logged In</text>
  </g>
  <g id="sd-node-loggingOut" class="sd-node sd-node--transient" style="--accent:#7d5ba6">
    <rect class="sd-node-pill" x="194" y="270" width="132" height="52" rx="26"/>
    <text class="sd-node-label" x="260" y="296">Logging Out…</text>
  </g>
</g>
"""
