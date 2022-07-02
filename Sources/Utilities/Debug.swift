public enum Debug
{
    public static func print(_ msg: Any)
    {
#if DEBUG
//        Swift.print("===>", msg)
#endif
    }
}
