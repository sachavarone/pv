##################################
# enhance data                   #
##################################

# add columns to df_preference, so that handling is easier
function enhancepreference(df_preference, df_occurrence, df_activity)
    # get idoccurrence, idactivity, inactive, occurrencebegin into preference
    df = df_preference;
    df = leftjoin(df, df_occurrence[:,[:idoccurrence, :idactivity, :inactive, :occurrencebegin]], on=:idoccurrence);
    df = leftjoin(df, df_activity[:,[:idactivity, :similarity, :pricefixed, :pricechild, :minchild, :maxchild]], on=:idactivity);

    # delete rows with missing values
    delete!(df, findall(.!completecases(df)))

    return df
end

# add idpreference to df_lifetime if it exists; else remove rows
function enhancelifetime(df_lifetime, df_preference, df_occurrence)
    df = df_preference[:,[:idpreference, :idoccurrence, :idpasseport]];
    # add idactivity to df_preference
    df = leftjoin(df, df_occurrence[:,[:idoccurrence, :idactivity]], on=:idoccurrence);
    # add idpreference to df_lifetime
    df = innerjoin(df_lifetime, df[:,[:idactivity, :idpasseport, :idpreference]], on=[:idactivity, :idpasseport]);

    return df
end

# add idpreference to df_assigned
# Warning : the pre-assignment should exist in the preferences !!!!
function enhanceassigned(df_assigned, df_preference)
    # add idpreference to df_assigned
    df = innerjoin(df_assigned, df_preference[:,[:idpasseport, :idoccurrence, :idpreference]], on=[:idpasseport, :idoccurrence])

    return df
end

# add zscore to df_preference
# Note: usefull for the computation of the objective function
#       this will be the choice score for each preference
# input : dfp = df_preference
#         dfo = df_occurrence
function computeChoiceScore(dfp, dfo)
    # set the number of choices
    nbchoice = maximum(dfp[:, :choice])

    # how to specify the number of choices per day ?
    # group by child and by day to find the number of choices
    # refer to this to apply the penalities

    # get the preference fields
    df = dfp[:,[:idpasseport, :idoccurrence, :choice]];
    # add the occurrence datetime
    df = innerjoin(df, dfo[:,[:idoccurrence, :occurrencebegin]], on=[:idoccurrence]);
    # compute the day
    df[!,:occurrencedate] = Dates.Date.(df[:,:occurrencebegin]);
    # initialize a new field
    df[!,:missingchoice] .= 0
    # group by idpasseport and day
    for subdf in groupby(df, [:idpasseport, :occurrencedate])
      subdf[:,:missingchoice] .= nbchoice-nrow(subdf)
    end
    # compute the rectificated choice to penalize missing choices
    df[!, :rectifiedchoice] = map((x,y) -> min(nbchoice, x+y), df[:,:choice], df[:,:missingchoice])
    # compute the preference values
    df[!, :zpref] =
        map(x -> 2^(nbchoice - x), df[:, :rectifiedchoice])

    return df[:,:zpref]
end
