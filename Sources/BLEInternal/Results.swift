public enum Results {
    public static func combineAll<T, E: Error>(_ results: [Result<T, E>]) -> Result<[T], E> {
        var successResults: [T] = []
        for result in results {
            switch result {
            case .success(let value):
                successResults.append(value)
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(successResults)
    }
}
