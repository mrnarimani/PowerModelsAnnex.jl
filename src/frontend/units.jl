# This will soon become its own package, but is not yet.
module Units

using Unitful
using Missings
using Base.Dates

export round, mean, asqtype, ustrip, fustrip, UnitfulMissing

import Base: round, mean, *, convert
import Unitful: @derived_dimension, ustrip, uconvert, Quantity, W, hr, J, 𝐋, 𝐌, 𝐓

UnitfulMissing = Union{<:Unitful.Quantity, Missings.Missing}

@derived_dimension PowerHour 𝐋^2*𝐌*𝐓^-2
@unit Wh "Wh" WattHour 3600J true

@derived_dimension ReactivePowerHour 𝐋^2*𝐌*𝐓^-2
@unit VARh "VARh" VARHour 3600J true

@dimension Money "Money" Currency
@refunit USD "USD" Currency Money false

round(x::AbstractArray{<:Quantity}, r::Int) = round(ustrip(x), r) * unit(eltype(x))
round{T<:Quantity}(x::T, r::Int) = round(ustrip(x), r) * unit(x)
mean(x::AbstractArray{<:Quantity}, r::Int) = mean(ustrip(x), r) * unit(eltype(x))
asqtype{T<:Unitful.Units}(x::T) = typeof(1.0*x)
#ustrip{T<:Unitful.Quantity}(x::DataArrays.DataArray{T}) = map(t -> ustrip(t), x)
ustrip(x::Missings.Missing) = x
fustrip{T<:Any}(x::Array{T}) = map(t -> ustrip(t), x)

Unitful.register(current_module())

*{T<:Unitful.FreeUnits}(y::Missings.Missing, x::T) = y

*(x::Unitful.Units, y::Number) = *(y, x)

# Handle working with `Period`s
*(x::Unitful.Units, y::Period) = *(y, x)
*(x::Period, y::Unitful.Units) = convert(y, x)
function convert(a::Unitful.Units, x::Period)
    sec = Dates.value(Dates.Second(x))
    uconvert(a, (sec)u"s")
end

# Methods to drop
# Exist to test that (offsets)u"hr" should work the same way
dt2umin(t::AbstractArray{Dates.Minute}) = Dates.value.(t).*u"minute"

# Some gymnastics needed to get this to work at run-time.
# Sourced from https://github.com/ajkeller34/UnitfulUS.jl
const localunits = Unitful.basefactors
function __init__()
    merge!(Unitful.basefactors, localunits)
    Unitful.register(Units)
end

end
