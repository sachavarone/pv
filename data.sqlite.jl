using SQLite

################
# SQLite       #
################

# Data access
function getData_db(dbname::String, tablename::String)
    # compose the SQL query
    sqlquery = string("SELECT * from ", tablename)
    # attach the database
    db = SQLite.DB(dbname)
    # execute the SQL query
    result = DBInterface.execute(db, sqlquery) |> DataFrame
    # add field names at least if no row available
    if nrow(result) == 0
        # set the query to get field names
        sqlquery = string("PRAGMA table_info(", tablename, ")")
        # execute the query
        fieldname = DBInterface.execute(db, sqlquery) |> DataFrame
        # add field names
        for label in fieldname[:,:name]
            result[!,Symbol(label)] = []
        end # for label in fieldname[:,name]
    end # if nrow(result) == 0
  return result
end # function getData_db

# Data write to db
function writeData_db(dbname::String, df::DataFrame)
  db = SQLite.DB(dbname)
  SQLite.load(db,"solution",df)
end # function writeData_db

function getdatasqlite(dbnamepv::String)
    # get activities
    df_activity = getData_db(dbnamepv, "activity")
    # get assigned
    df_assigned = getData_db(dbnamepv, "assigned")
    # get dataframe of occurrences
    df_occurrence = getData_db(dbnamepv, "occurrence")
    # get children
    df_child = getData_db(dbnamepv, "child")
    # get knome
    df_knome = getData_db(dbnamepv, "knome")
    # get preferences
    df_preference = getData_db(dbnamepv, "preference")
    # get lifetime
    df_lifetime = getData_db(dbnamepv, "lifetime")
    # get period
    df_period = getData_db(dbnamepv, "period")

    # specify the date format from the provider
    dateformat = Dates.DateFormat("dd.mm.yyyy HH:MM:SS")
    # convert child birthdate format
    if (nrow(df_child) > 0) && (Date != typeof(df_child[1, :birthdate]))
        df_child[!, :birthdate] = Date.(df_child[:, :birthdate], dateformat)
    end
    # convert occurrence begin and end format
    if (nrow(df_occurrence) > 0) &&
       (DateTime != typeof(df_occurrence[1, :occurrencebegin]))
        df_occurrence[!, :occurrencebegin] =
            DateTime.(df_occurrence[:, :occurrencebegin], dateformat)
    end
    if (nrow(df_occurrence) > 0) &&
       (DateTime != typeof(df_occurrence[1, :occurrenceend]))
        df_occurrence[!, :occurrenceend] =
            DateTime.(df_occurrence[:, :occurrenceend], dateformat)
    end
    # convert period begin and end format
    if (nrow(df_period) > 0) && (DateTime != typeof(df_period[1, :periodbegin]))
        df_period[!, :periodbegin] =
            DateTime.(df_period[:, :periodbegin], dateformat)
    end
    if (nrow(df_period) > 0) && (DateTime != typeof(df_period[1, :periodend]))
        df_period[!, :periodend] =
            DateTime.(df_period[:, :periodend], dateformat)
    end

    # correct the date in occurrencebegin and occurrenceend
    df_occurrence = temporaryChangeDate(df_occurrence)

    return df_child,
    df_activity,
    df_period,
    df_lifetime,
    df_occurrence,
    df_preference,
    df_knome,
    df_assigned

end # getdatasqlite

# correct the date in occurrencebegin and occurrenceend
function temporaryChangeDate(df_occurrence::DataFrame)
    # set temporary DataFrame
    df = df_occurrence;
    # check if ehe dateframe is not empty and occurrencedate exists
    if (nrow(df) > 0) && (in("occurrencedate",names(df)))
        # specify the date format from the provider
        dateformat = Dates.DateFormat("dd.mm.yyyy HH:MM:SS")
        # correct the date format in occurrencedate))
        if (DateTime != typeof(df[1, :occurrencedate]))
            df[!, :occurrencedate] = Date.(df[:, :occurrencedate], dateformat)
        end # if (DateTime != typeof(df[1, :occurrencedate]))
        # compose the correct datetime for the beginning of occurrence
        df[!,:occurrencebegin]=map(x->DateTime(Dates.Year(x[1]), Dates.Month(x[1]), Dates.Day(x[1]),
                                                        Dates.Hour(x[2]), Dates.Minute(x[2]), Dates.Second(x[2])),
                                                        zip(df[:,:occurrencedate], df[:,:occurrencebegin]));
        # compose the correct datetime for the end of occurrence
        df[!,:occurrenceend]=map(x->DateTime(Dates.Year(x[1]), Dates.Month(x[1]), Dates.Day(x[1]),
                                                        Dates.Hour(x[2]), Dates.Minute(x[2]), Dates.Second(x[2])),
                                                        zip(df[:,:occurrencedate], df[:,:occurrenceend]));
        # delete the lifetime field in lifetime
        select!(df, Not(:occurrencedate))
    end # if (nrow(df) > 0) && (in("occurrencedate",names(df)))

    return df
end # function temporaryChangeDate
