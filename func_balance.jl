################################
##  Improve cost balancing    ##
################################


# set the age category
function setAgeCategory(birthdate::Date, agecat::Array{Date})
  # set by default to the oldest category
  agecategory = 1
  while birthdate > agecat[agecategory] && agecategory < length(agecat)
    # the child is younger than the current category
    agecategory += 1
  end # while birthdate
  if birthdate > agecat[agecategory]
   # age category is then the last one, i.e. the youngest one
    agecategory += 1
  end # if birthdate
  return agecategory
end # function setAgeCategory

# prepare for analysis
# dfp = dataframe of preferences
function addcost(sol, dfp::DataFrame)
    # internal dataframe
    dftemp = dfp
    # test if column "nbchildren" exists
    if Symbol("nbchildren") in names(dfp)
        # delete column "nbchildren"
        select!(dftemp, Not(:nbchildren))
    end # if Symbol
    # add solution as a boolean assignement to preference dataframe
    dftemp[!,:assigned] = map(x -> sol[x] > 0.1 , dftemp[:,:idpreference]);
    # add cost child to preference dataframe
    dftemp[!,:assignedpricechild] = map((x,y) -> x*y, dftemp[:,:assigned], dftemp[:,:pricechild]);
    # get the number of children assigned by occurrence
    dfnb = combine(df -> sum(df[:,:assigned]), groupby(dftemp, :idoccurrence));
    # rename x1 into nbchildren
    rename!(dfnb, :x1 => :nbchildren)
    # add nbchildren into dftemp
    dftemp = leftjoin(dftemp, dfnb, on = :idoccurrence)

    # add cost fixed to preference dataframe
    dftemp[!,:assignedpricefixed] = map((x,y) -> if y>0 x/y else 0 end, dftemp[:,:pricefixed], dftemp[:,:nbchildren])
    # add cost assignement to preference dataframe
    dftemp[!,:assignedcost] = dftemp[:,:assignedpricechild] + dftemp[:,:assignedpricefixed]
    # remove unnecessary fields
    select!(dftemp, Not([:assignedpricechild, :assignedpricefixed]))
    # return result
    return dftemp
end # function addcost

# prepare for analysis
# dfp = dataframe of preferences
function removecost(dfp::DataFrame)
    # internal dataframe
    dftemp = dfp
    # remove unnecessary fields
    deletecols!(dftemp, [:assigned, :nbchildren, :assignedcost])#delete!(dftemp, [:assigned, :nbchildren, :assignedcost])
    # return result
    return dftemp
end # function addcost

# prepare for analysis
# dfp = dataframe of preferences
function getcost(dfp::DataFrame, agecat::Array{Date}, df_child)
    # sum the cost by child for assigned occurrences
    dfc = combine(df -> sum(df[:,:assignedcost]), groupby(dfp[dfp[:,:assigned],:], :idpasseport))
    # rename column x1 into a more explicit name
    rename!(dfc,:x1 => :cumcost)#rename!(dfc,:x1,:cumcost)
    # add the birthdates
    dfc = leftjoin(dfc, df_child, on = :idpasseport)
    # transform birthdates into Date format
    dfc[!,:birthdate] = map(x -> Date(x), dfc[:,:birthdate])
    # set the age category
    dfc[!,:agecategory] = map(x -> setAgeCategory(x, agecat), dfc[:,:birthdate])
    # return cost dataframe
    return dfc
  end # function prepareanalysis

# dfc = dataframe of cost
function doanalysis(dfc::DataFrame, zvalue::Float64)
  # compute the mean per age category restricted to assigned occurrences
  msol = combine( d -> mean(d[:,:cumcost]), groupby(dfc, :agecategory))
  # rename x1 into a more explicit name
  rename!(msol,:x1 => :msol)#rename!(msol,:x1,:msol)
  # compute the standard deviation per age category restricted to assigned occurrences
  sdsol = combine(d -> std(d[:,:cumcost]), groupby(dfc, :agecategory))
  # rename x1 into a more explicit name
  rename!(sdsol,:x1 => :sdsol)#rename!(sdsol,:x1,:sdsol)
  # build a dataframe of analysis
  df_analysis = innerjoin(msol, sdsol, on = :agecategory)
  # compute the number of children to assigned occurrences
  nbchild = combine(nrow, groupby(dfc, :agecategory))
  # rename x1 into a more explicit name
  rename!(nbchild,:nrow => :nbchild)#rename!(nbchild,:x1,:nbchild)
  # add number of children by category
  df_analysis = innerjoin(df_analysis, nbchild, on = :agecategory)
  # compute the outlier  limit by age category
  df_analysis[!,:threshold] = map((m,s) -> m+zvalue*s, df_analysis[:,:msol], df_analysis[:,:sdsol])
  # compute the coefficient of variation
  df_analysis[!,:cv] = map((s,m) -> if m!=0 s/m else NaN end, df_analysis[:,:sdsol], df_analysis[:,:msol])
  # set the threshold value
  dfc = leftjoin(dfc, df_analysis, on = :agecategory)
  # set the condition for being an outlier
  dfc[!,:exceed] = map((x,y) -> x > y, dfc[:,:cumcost], dfc[:,:threshold])
  # count the number of outliers
  dftemp = combine(d -> sum(d[:,:exceed]), groupby(dfc, :agecategory))
  # set in the analysis dataframe
  df_analysis[!,:nbexceed] = dftemp[:,:x1]
  # return the analysis and the cost
  return df_analysis, dfc
end # function doanalysis

# get true or false condition on balancing
# dfp = df_preference
# dfc = df_cost
function conditiontobalance(dfp::DataFrame, dfc::DataFrame, status::Symbol)
  # status of the optimisation should be "Optimal"
  if status != Symbol("Optimal")
    return false
  end # if status

  # add exceed, agecategory, threshold into preferences
  catagedf = leftjoin(dfp,
                  dfc[[:idpasseport, :agecategory, :exceed, :threshold]],
                  on = :idpasseport);
  if sum(catagedf[:exceed]) > 0
      return true
  end # if

  # not all conditions apply since this is executed
  return false
end # function conditiontobalance
