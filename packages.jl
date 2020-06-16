using Pkg

# get packages dependencies
deps = Pkg.dependencies()
# find installed packages
installs = Dict{String, VersionNumber}()
for (uuid, dep) in deps
    dep.is_direct_dep || continue
    dep.version === nothing && continue
    installs[dep.name] = dep.version
end

if ! in("CSV",keys(installs))
	Pkg.add("CSV")
end
using CSV

if ! in("DataFrames",keys(installs))
	Pkg.add("DataFrames")
end
using DataFrames

if ! in("Cbc",keys(installs))
	Pkg.add("Cbc")
end
using Cbc

if ! in("Gurobi",keys(installs))
	Pkg.add("Gurobi")
end
using Gurobi

if ! in("JuMP",keys(installs))
	Pkg.add("JuMP")
end
using JuMP

if ! in("Dates",keys(installs))
	Pkg.add("Dates")
end
using Dates

if ! in("Statistics",keys(installs))
	Pkg.add("Statistics")
end
using Statistics

if ! in("SQLite",keys(installs))
	Pkg.add("SQLite")
end
using SQLite

# if ! in("Distributions",keys(installs))
# 	Pkg.add("Distributions")
# end
# using Distributions
#
# if ! in("Test", keys(installs))
# 	Pkg.add("Test")
# end
# using Test
