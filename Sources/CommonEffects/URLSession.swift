import Foundation

extension URLSession
{
    public func fetchData(
        for urlRequest: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> Data
    {
        if #available(iOS 15.0, *) {
            let (data, _) = try await self.data(for: urlRequest, delegate: nil)
            return data
        } else {
            let task = Task<Data, Swift.Error> {
                let data: Data = try await withUnsafeThrowingContinuation { continuation in
                    let sessionTask = self.dataTask(with: urlRequest) { data, _, error in
                        if let data = data {
                            continuation.resume(returning: data)
                        }
                        else if let error = error {
                            continuation.resume(throwing: error)
                        }
                        else {
                            fatalError("Should never reahc here")
                        }
                    }
                    sessionTask.resume()
                }
                return data
            }

            let data = try await withTaskCancellationHandler {
                try await task.value
            } onCancel: {
                task.cancel()
            }

            return data
        }
    }
}
