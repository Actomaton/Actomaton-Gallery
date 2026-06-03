#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(WASILibc)
import WASILibc
#endif
import VectorMath

func sin(_ value: Scalar) -> Scalar
{
    Scalar(cSin(Double(value)))
}

func cos(_ value: Scalar) -> Scalar
{
    Scalar(cCos(Double(value)))
}

func sqrt(_ value: Scalar) -> Scalar
{
    Scalar(cSqrt(Double(value)))
}

func pow(_ value: Scalar, _ exponent: Int) -> Scalar
{
    Scalar(cPow(Double(value), Double(exponent)))
}

private func cSin(_ value: Double) -> Double
{
#if canImport(Darwin)
    Darwin.sin(value)
#elseif canImport(Glibc)
    Glibc.sin(value)
#elseif canImport(WASILibc)
    WASILibc.sin(value)
#else
    fatalError("No C math module is available.")
#endif
}

private func cCos(_ value: Double) -> Double
{
#if canImport(Darwin)
    Darwin.cos(value)
#elseif canImport(Glibc)
    Glibc.cos(value)
#elseif canImport(WASILibc)
    WASILibc.cos(value)
#else
    fatalError("No C math module is available.")
#endif
}

private func cSqrt(_ value: Double) -> Double
{
#if canImport(Darwin)
    Darwin.sqrt(value)
#elseif canImport(Glibc)
    Glibc.sqrt(value)
#elseif canImport(WASILibc)
    WASILibc.sqrt(value)
#else
    fatalError("No C math module is available.")
#endif
}

private func cPow(_ value: Double, _ exponent: Double) -> Double
{
#if canImport(Darwin)
    Darwin.pow(value, exponent)
#elseif canImport(Glibc)
    Glibc.pow(value, exponent)
#elseif canImport(WASILibc)
    WASILibc.pow(value, exponent)
#else
    fatalError("No C math module is available.")
#endif
}
