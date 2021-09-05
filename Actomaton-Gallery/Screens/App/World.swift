import Foundation
import Combine

struct Environment
{
    let urlSession: URLSession
    let getDate: () -> Date

    var github: GitHub.Environment
    {
        GitHub.Environment(
            urlSession: urlSession,
            searchRequestDelay: 0.3,
            imageLoadMaxConcurrency: 3
        )
    }

    var stopwatch: Stopwatch.Environment
    {
        Stopwatch.Environment(
            getDate: getDate
        )
    }
}

func makeRealEnvironment() -> Environment
{
    Environment(
        urlSession: URLSession.shared,
        getDate: { Date() }
    )
}
