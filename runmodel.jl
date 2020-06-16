
#Install and call the packages
include("packages.jl")
# definitions constantes
include("pvdefinitions.jl")
# read the data from sqlite database
include("data.sqlite.jl");
# read the data from csv files
include("data.csv.jl");
# convertion of the provider's data file
include("data.convert.csv.jl");
# data preparation (enhanced)
include("data.enhance.csv.jl");
# constraint functions
include("func_constraint.jl")
# balance constraint functions
include("func_balance.jl")
# create the MIP model
include("createmodel.jl");
# get and write the solution
include("solution.jl")
# unit testing
include("unittest.jl")

# Function to solve different problem with only one compilation
# pathtodata => path to the csv files containing all the data needed to solve the problem
function createandsolve(pathtodata::String; solver::String = "CBC")
    # filename for parameters
    filenameParameter = string(pathtodata, "userparam.csv")

    # get the different parameter given by the user
    csvseparator, weightChoice, weightCost, mincv, zvalue, agecategorylimit =
        getParamcsv(filenameParameter)

    df_child,
    df_activity,
    df_period,
    df_lifetime,
    df_occurrence,
    df_preference,
    df_knome,
    df_assigned = getdatacsv(pathtodata)

    #join data
    df_lifetime = enhancelifetime(df_lifetime, df_preference, df_occurrence)
    df_preference = enhancepreference(df_preference, df_occurrence, df_activity)
    df_assigned = enhanceassigned(df_assigned, df_preference)
    # compute choice score
    df_preference[!,:zpref] = computeChoiceScore(df_preference, df_occurrence)

    # start CPU computation
    # cputime1 = @elapsed begin
    # create the model
    m = createmodel(
        df_child,
        df_activity,
        df_period,
        df_lifetime,
        df_occurrence,
        df_preference,
        df_knome,
        df_assigned,
        weightChoice,
        weightCost,
        solver
    )
    # solve the problem
    optimize!(m)
    status = termination_status(m)
    # initialize a counter
    #get the solution and store int csv file
    solution, df_analysis = getsolution(
        status,
        df_preference,
        df_occurrence,
        df_child,
        zvalue,
        m,
        agecategorylimit,
    )
    remainder =
        getremainder(solution, df_occurrence, df_activity)

    # write solution
    writeSolution(pathtodata, solution)
    # write solution
    writeRemainder(pathtodata, remainder)
    # write the analysis
    println(df_analysis);
    # write the number of selected choices
    println(combine(nrow, groupby(solution[:, :], :choice)))
    # write the number of assignements
    println("Number assigned = ", nrow(solution))

    # end
    # print("Single index CPU time = ", div(cputime1,60)," minutes and ", rem(cputime1,60), " seconds\n")

    # return the solution
    return solution, remainder
end # function createandsolve


# change working directory to the one containing this file
cd(@__DIR__)
# set the solver
solver = "GUROBI"
# set the path to data
pathtodata = "../../data/test/"
# pathtodata = "../../data/2019/small/"
# pathtodata = "../../data/2019/lausanne/"
# pathtodata = "../../data/2019/Morges/"
# pathtodata = "../../data/2019/Neuchatel/"
# pathtodata = "../../data/2019/Gland/"
# pathtodata = "../../data/2019/Yverdon/"
# pathtodata = "../../data/2019/Aubonne/"
# pathtodata = "../../data/2019/Aubonnemini/"

# filename for parameters
filenameParameter = string(pathtodata, "userparam.csv")
# get the different parameter given by the user
csvseparator, weightChoice, weightCost, mincv, zvalue, agecategorylimit =
    getParamcsv(filenameParameter)

# # get the data
# df_child,
# df_activity,
# df_period,
# df_lifetime,
# df_occurrence,
# df_preference,
# df_knome,
# df_assigned = getdatacsv(pathtodata)

# set the name of the database
dbnamepv = string(pathtodata, "pv_morges.db")
# get the data
df_child,
df_activity,
df_period,
df_lifetime,
df_occurrence,
df_preference,
df_knome,
df_assigned = getdatasqlite(dbnamepv)

#join data
df_lifetime = enhancelifetime(df_lifetime, df_preference, df_occurrence)
df_preference = enhancepreference(df_preference, df_occurrence, df_activity)
df_assigned = enhanceassigned(df_assigned, df_preference)
# compute choice score
df_preference[!,:zpref] = computeChoiceScore(df_preference, df_occurrence)

# start CPU computation
# cputime1 = @elapsed begin
# create the model
m = createmodel(
    df_child,
    df_activity,
    df_period,
    df_lifetime,
    df_occurrence,
    df_preference,
    df_knome,
    df_assigned,
    weightChoice,
    weightCost,
    solver
)
# solve the problem
optimize!(m)
status = termination_status(m)
# initialize a counter
#get the solution and store int csv file
solution, df_analysis = getsolution(
    status,
    df_preference,
    df_occurrence,
    df_child,
    zvalue,
    m,
    agecategorylimit,
)
remainder =
    getremainder(solution, df_occurrence, df_activity)

# write solution
writeSolution(pathtodata, solution)
# write solution
writeRemainder(pathtodata, remainder)
# write the analysis
println(df_analysis);
# write the number of selected choices
println(combine(nrow, groupby(solution[:, :], :choice)))
# write the number of assignements
println("Number assigned = ", nrow(solution))

# #unit tests to verify that all the occurrences of a multi-occurence activity are assigned and that there is no overlappong in the assgnations
# @test testMultioccurrences(solution)
# @test testOverlapping(solution)
