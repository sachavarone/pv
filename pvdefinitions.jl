###############
# definitions #
###############

# simulated data for different instances' sizes
testonlysmall = [5, 10, 2, 4]
testonly = [50, 10, 2, 4]
Morges = [700, 300, 4, 14]
Lausanne = [1500, 300, 4, 14]
Yverdon = [500, 250, 4, 14]
Cossonay = [350, 150, 4, 8]
Neuchatel = [650, 250, 4, 14]
Aubonne = [300, 110, 4, 5]

function openFiles(pathtodata)
    # filename for parameters
    filenameParameter = string(pathtodata, "userparam.csv")
    # filename for children
    filenameChild = string(pathtodata, "child.csv")
    # filename for knome
    filenameKnome = string(pathtodata, "knome.csv")
    # filename for activities
    filenameActivity  = string(pathtodata, "activity.csv")
    # filename for lifetime activities
    filenameLifetime = string(pathtodata, "lifetime.csv")
    # filename for occurrences
    filenameoccurrence = string(pathtodata, "occurrence.csv")
    # filename for preferences
    filenamePreference = string(pathtodata, "preference.csv")
    # filename for period
    filenamePeriod = string(pathtodata, "period.csv")
    # filename for solution
    filenameSolution = string(pathtodata, "solution/solution.csv")
    # filename for Remainder
    filenameRemainder = string(pathtodata, "solution/remainder.csv")
    # filename for pre-assignment
    filenameAssigned = string(pathtodata, "assigned.csv")

    return filenameParameter, filenameChild, filenameKnome, filenameActivity, filenameLifetime, filenameoccurrence, filenamePreference, filenamePeriod, filenameSolution, filenameRemainder, filenameAssigned
end


# # sql query occurrence
# sqlquery_occurrence = "SELECT * FROM occurrence"
# # sql query activity
# sqlquery_activity = "SELECT * FROM activity"
# # sql query child
# sqlquery_child = "SELECT idchild, birthdate FROM child"
# # sql query knome
# sqlquery_knome = "SELECT * FROM knome"
# # sql query period
# sqlquery_period = "SELECT * FROM period"
# # sql query preference
# sqlquery_preference = "SELECT activity.similarity as similarity,
#             activity.pricefixed as pricefixed,
#             activity.pricechild as pricechild,
#             activity.minchild as minchild,
#             activity.maxchild as maxchild,
#             a.*
#             FROM activity
#             INNER JOIN
#                       (SELECT preference.*,
#                       occurrence.idactivity, occurrence.inactive, occurrence.occurrencebegin
#                         FROM preference
#                         LEFT JOIN child
#                           ON preference.idchild=child.idchild
#                         LEFT JOIN occurrence
#                           ON preference.idoccurrence=occurrence.idoccurrence) a
#             ON activity.idactivity=a.idactivity
#             ORDER BY idpreference"
# # sql query lifetime
# sqlquery_lifetime = "SELECT lifetime.*, a.idpreference as idpreference
#             FROM lifetime
#             INNER JOIN
#               (SELECT preference.*, occurrence.idactivity as idactivity
#               FROM preference
#               LEFT JOIN occurrence
#                 ON preference.idoccurrence=occurrence.idoccurrence) a
#             ON lifetime.idchild=a.idchild AND lifetime.idactivity=a.idactivity
#             ORDER BY lifetime.idlifetime"
