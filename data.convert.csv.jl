##########################################################
# Goal: convertion from provider's data into clean data  #
##########################################################


function dataconvertcsv(df_child, df_activity, df_period, df_lifetime,
						df_occurrence, df_preference, df_knome, df_assigned)

	uninitialized="missing";#"NA"

	# specify the date format from the provider
	dateformat = Dates.DateFormat("dd.mm.yyyy HH:MM:SS");

	# rename pricefixe into pricefixed
	if "pricefixe" in names(df_activity)
		rename!(df_activity, :pricefixe => :pricefixed);#rename!(df_activity, :pricefixe, :pricefixed);
	end
	# rename idperiode into idperiod
	if "idperiode" in names(df_period)
		rename!(df_period, :idperiode => :idperiod);#rename!(df_period, :idperiode, :idperiod);
	end
	# rename idpassepoprt into idpasseport
	if "idpassepoprt" in names(df_preference)
		rename!(df_preference, :idpassepoprt => :idpasseport);#rename!(df_preference, :idpassepoprt, :idpasseport);
	end

	# convert birthdate format
	if (Date != typeof(df_child[1,:birthdate]))
		df_child[!,:birthdate]  = map(x -> Date(x, dateformat), df_child[:,:birthdate]);
	end
	# convert occurrencedate format
	if (:occurrencedate in names(df_occurrence))
		df_occurrence[!,:occurrencedate]=map(x ->Date(x, dateformat) , df_occurrence[:,:occurrencedate]);
	end

	# convert periodbegin format
	df_period[!,:periodbegin]=DateTime.(df_period[:,:periodbegin],dateformat)
	# convert periodend format
	df_period[!,:periodend]=DateTime.(df_period[:,:periodend],dateformat)

	# choose a fake date in case of missing values
	fakedatetime = minimum(DateTime.(collect(skipmissing(df_occurrence[:,:occurrenceend])), dateformat))#DateTime(minimum(df_occurrence[:,occurrencedate]));

	# convert datetime format
	df_occurrence[!,:occurrencebegin]=map(x -> if ismissing(x) fakedatetime else DateTime(x, dateformat) end, df_occurrence[:,:occurrencebegin]);
	# convert datetime format
	df_occurrence[!,:occurrenceend]=map(x ->  if ismissing(x) fakedatetime else DateTime(x, dateformat) end, df_occurrence[:,:occurrenceend]);
	# convert into a date DateFormat
	df_occurrence[!,:occurrencedate]  = map(x -> Date(x, dateformat), df_occurrence[:,:occurrencedate]);
	# compose the correct datetime for the beginning of occurrence
	df_occurrence[!,:occurrencebegin]=map(x->DateTime(Dates.Year(x[1]), Dates.Month(x[1]), Dates.Day(x[1]),
	                                                Dates.Hour(x[2]), Dates.Minute(x[2]), Dates.Second(x[2])),
	                                                zip(df_occurrence[:,:occurrencedate], df_occurrence[:,:occurrencebegin]));

	# compose the correct datetime for the end of occurrence
	df_occurrence[!,:occurrenceend]=map(x->DateTime(Dates.Year(x[1]), Dates.Month(x[1]), Dates.Day(x[1]),
	                                                Dates.Hour(x[2]), Dates.Minute(x[2]), Dates.Second(x[2])),
	                                                zip(df_occurrence[:,:occurrencedate], df_occurrence[:,:occurrenceend]));
	# set the next occurrence in case of multiple occurrence for a same activity
	df_occurrence[!,:next]=map(x->if ismissing(x[1]) x[2]
	                            else x[1] end, zip(df_occurrence[:,:next], df_occurrence[:,:idoccurrence]));
	# set the previous occurrence in case of multiple occurrence for a same activity
	df_occurrence[!,:previous]=map(x->if ismissing(x[1]) x[2]
	                                else x[1] end, zip(df_occurrence[:,:previous], df_occurrence[:,:idoccurrence]));
	# convert inactive from -1 to 1
	df_occurrence[!,:inactive]=map(x->if ismissing(x) | x==0 Int(0) else 1 end, df_occurrence[:,:inactive]);

	# add the idlifetime field in lifetime
	df_lifetime[!,:idlifetime] = 1:nrow(df_lifetime);
	# get the idchild field in lifetime
	df_lifetime = leftjoin(df_lifetime, df_child[:,[:idpasseport]], on = :idpasseport);

	# delete the occurrencedate field in occurrence
	select!(df_occurrence, Not(:occurrencedate))
	# delete the lifetime field in lifetime
	select!(df_lifetime, Not(:lifetime))

	return df_child, df_activity, df_period, df_lifetime, df_occurrence, df_preference, df_knome, df_assigned
end
