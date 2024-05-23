public enum Requirement: String, Codable, Equatable, CaseIterable {
    case mandatory = "M"
    case optional = "O"
    case excluded = "X"
    case notApplicable = "N/A"
}
