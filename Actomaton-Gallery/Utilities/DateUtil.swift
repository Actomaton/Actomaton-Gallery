import Foundation
import Combine

enum DateUtil {}

extension DateUtil
{
    static func getDate<Action>(
        next: @escaping (Date) -> Action
    )
        -> (_ makeDate: @escaping () -> Date)
        -> AnyPublisher<Action, Never>
    {
        { makeDate in
            Deferred { Just(makeDate()) }
                .map(next)
                .eraseToAnyPublisher()
        }
    }

    static func timeString(time: TimeInterval) -> String
    {
        self.dateFormtter.string(from: Date(timeIntervalSince1970: time))
    }

    private static let dateFormtter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss.SS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
