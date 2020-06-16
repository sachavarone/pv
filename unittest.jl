## Test solution
#test to verify that all the occurrences of a multi-occurrence activity are assigned
function testMultioccurrences(solution)
	# flag to true
	testPassed = true
	# group by idpasseport
	groupPasseport = groupby(solution, [:idpasseport])
	for g in groupPasseport
		for thenext in g[:,:next]
			# each next occurrence should have been assigned to this idpasseport
			if !(thenext in g[:,:idoccurrence])
				testPassed = false
				# println(g[1,:idpasseport])
			break
		end # if
		end # for thenext in g[;next]
	end # for g in groupPasseport
	return testPassed
end

## Test solution
#test to verify that no assignations are overlapping for a child
function testOverlapping(solution)
	testPassed = true
	groupPasseport = groupby(solution, [:idpasseport])
	for g in groupPasseport
		sorted = sort(g[:,[:occurrencebegin, :occurrenceend]], :occurrencebegin)
		if ! all(sorted[1:end-1,:occurrenceend]<=sorted[2:end, :occurrencebegin])
			testPassed = false
			# print(g[:idpasseport])
		end
	end
	return testPassed
end
