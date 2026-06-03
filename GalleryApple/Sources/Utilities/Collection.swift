extension MutableCollection
{
    /// Safe get / set element for `MutableCollection`.
    public subscript (safe index: Index) -> Iterator.Element?
    {
        get {
            self.startIndex <= index && index < self.endIndex
                ? self[index]
                : nil
        }
        set {
            guard let newValue = newValue, self.startIndex <= index && index < self.endIndex else { return }
            self[index] = newValue
        }
    }
}
