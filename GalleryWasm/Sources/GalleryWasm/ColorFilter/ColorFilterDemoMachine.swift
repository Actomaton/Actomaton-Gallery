import Actomaton
import ColorFilter
import Reactivity

@Reactive
final class ColorFilterState
{
    var colorFilter: ColorFilter.State = .init()
}

typealias ColorFilterDemoMachine = MealyDriver<ColorFilter.Action, ColorFilterState, Never>

func makeColorFilterDemoMachine(state: ColorFilterState = ColorFilterState()) -> ColorFilterDemoMachine
{
    ColorFilterDemoMachine(
        state: state,
        reducer: ColorFilter.reducer
            .contramap(state: \ColorFilterState.colorFilter),
        environment: ()
    )
}
