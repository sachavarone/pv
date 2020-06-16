#########################################
##  Get solution once system solved    ##
#########################################

# write the solution
function writeSolution(pathtodata::String, sol::DataFrame)
    # filename for solution
    filenameSolution = string(pathtodata, "solution/solution.csv")
    # write solution to a file
   CSV.write(filenameSolution, sol; delim=';');
   CSV.write(string(filenameSolution, "2"), sol; delim=',');

    # writeData_db(dbnamepv, solution)
end # function writeSolution

# write the remainder
function writeRemainder(pathtodata::String, df_remainder::DataFrame)
    # filename for remainder
    filenameRemainder = string(pathtodata, "solution/remainder.csv")
    # write solution to a file
    CSV.write(filenameRemainder, df_remainder; delim=';');
    CSV.write(string(filenameRemainder,"2"), df_remainder; delim=',');

    # writeData_db(dbnamepv, df_remainder)
end # function writeRemainder

function getsolution(status, df_preference, df_occurrence, df_child, zvalue, m, agecategorylimit)
    # status of the optimisation should be "Optimal"
    if status == MOI.OPTIMAL
        # get the solution
        solx = value.(m[:x]);

        # add the cost to df_preference
        dftemp = addcost(solx, df_preference);
        # get the cost per child dataframe
        df_cost = getcost(dftemp, agecategorylimit, df_child);
        # do the analysis
        df_analysis, df_cost = doanalysis(df_cost, zvalue);

        # only take useful data solution
        # solution = df_preference[df_preference[:,:assigned].==true,
        solution = dftemp[dftemp[:,:assigned].==true,
                                [:idpasseport, :idactivity, :idoccurrence, :choice,
                                :pricefixed, :pricechild, :assignedcost]]
        # add missing date information
        solution = leftjoin(solution, df_occurrence, on = [:idactivity, :idoccurrence])
        # add exceed status
        solution = leftjoin(solution, df_cost[:,[:idpasseport, :exceed]], on =  :idpasseport)

    else
        solution = 0
    end # if status

	return solution, df_analysis
end

# return the remaining units in assigned occurrences
function getremainder(solution, df_occurrence, df_activity)
    # case without solution
    if solution == 0 return 0 end

    effectif = combine(nrow, groupby(solution, :idoccurrence));
    rename!(effectif, :nrow => :effectif);
    df = leftjoin(df_occurrence, effectif, on=:idoccurrence);
    df = leftjoin(df, df_activity[:,[:idactivity, :minchild, :maxchild]], on=:idactivity);
    df[!,:effectif] = coalesce.(df[:,:effectif], 0);
    df[!,:remainder] = df[:,:maxchild] - df[:,:effectif];
    df[!,:freeratio] = df[:,:remainder] ./ df[:,:maxchild];

    # return remaining units in assigned occurrences
    return df
end
