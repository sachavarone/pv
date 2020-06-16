#load the csv files containing the data of the problem to solve
function datacsv(pathtodata, filenameParameter, filenameChild, filenameKnome,
    filenameActivity, filenameLifetime, filenameoccurrence, filenamePreference,
    filenamePeriod, filenameSolution, filenameAssigned, csvseparator)

    # create a directory "solution" if it does not exist
    if (isdir(pathtodata) & !isdir(string(pathtodata, "solution")))
        mkdir(string(pathtodata, "solution"))
    end

    # read the child data file
    df_child = CSV.read(filenameChild,header=true, delim=csvseparator)#readtable(filenameChild, separator = csvseparator);
    # read the activity data file
    df_activity = CSV.read(filenameActivity, header=true, delim=csvseparator)#readtable(filenameActivity, separator = csvseparator);
    # read the period data file
    df_period = CSV.read(filenamePeriod, header=true, delim=csvseparator)#readtable(filenamePeriod, separator = csvseparator);
    # read the lifetime data file
    df_lifetime = CSV.read(filenameLifetime, header=true, delim=csvseparator)#readtable(filenameLifetime, separator = csvseparator);
    # read the occurrence data file
    df_occurrence =  CSV.read(filenameoccurrence, header=true, delim=csvseparator)#readtable(filenameoccurrence, separator = csvseparator);#CSV.read(filenameoccurrence, types=Dict(3=>String, 4=>String, 5=>String, 7=>Int64, 8=>Int64));#readtable(filenameoccurrence, separator = csvseparator);#CSV.read(filenameoccurrence, types=Dict(7=>Int64, 8=>Int64));#readtable(filenameoccurrence, separator = csvseparator);#CSV.read(filenameoccurrence, nullable=true)#

    # read the preference data file
    df_preference = CSV.read(filenamePreference, header=true, delim=csvseparator);#readtable(filenamePreference, separator = csvseparator);#CSV.read(filenamePreference, header=true)#
    # read the knome data file
    df_knome = CSV.read(filenameKnome, header=true, delim=csvseparator)#readtable(filenameKnome, separator = csvseparator);
    # test if filenameAssiged exists
    if isfile(filenameAssigned)
    	# read the assigned data file
    	df_assigned = CSV.read(filenameAssigned, header=true, delim=csvseparator);
    else
    	# define an empty data frame
    	df_assigned=DataFrame(idpasseport = Int64[], idoccurrence = Int64[])
    end # if isfile


    return df_child, df_activity, df_period, df_lifetime, df_occurrence, df_preference, df_knome, df_assigned
end


#function to load and store the parameter given by the user
function getParamcsv(filename)
    param=CSV.read(filename, header=false)

    csvseparator = param[1,2][1]
    weightChoice = parse(Float64, param[2,2])
    weightCost = parse(Float64, param[3,2])
    mincv = parse(Float64, param[4,2])
    zvalue = parse(Float64, param[5,2])
    agecategorylimit = sort(Date.(param[6:end,2]))

    return csvseparator, weightChoice, weightCost, mincv, zvalue, agecategorylimit
end

# get data from csv and clean it
function getdatacsv(pathtodata::String)
    #get the path to each data file
    filenameParameter,
    filenameChild,
    filenameKnome,
    filenameActivity,
    filenameLifetime,
    filenameoccurrence,
    filenamePreference,
    filenamePeriod,
    filenameSolution,
    filenameRemainder,
    filenameAssigned = openFiles(pathtodata)
    
    #get the different parameter given by the user
    csvseparator, weightChoice, weightCost, mincv, zvalue, agecategorylimit =
        getParamcsv(filenameParameter)

    #read all the csv files and load into dataframes
    df_child,
    df_activity,
    df_period,
    df_lifetime,
    df_occurrence,
    df_preference,
    df_knome,
    df_assigned = datacsv( pathtodata,
        filenameParameter,
        filenameChild,
        filenameKnome,
        filenameActivity,
        filenameLifetime,
        filenameoccurrence,
        filenamePreference,
        filenamePeriod,
        filenameSolution,
        filenameAssigned,
        csvseparator,
    )
    #convert and correct the data
    return dataconvertcsv(
        df_child,
        df_activity,
        df_period,
        df_lifetime,
        df_occurrence,
        df_preference,
        df_knome,
        df_assigned)
end
