{fill, trackedMin} = require './util'

#
# Computes the Levenshtein distance (lev).
#
# @example
# var stringA = "abcdef";
# var stringB = "abdfgh";
# var insert = remove = function(char) { return 1; };
# var update = function(charA, charB) { return charA !== charB ? 1 : 0; };
# distance(stringA, stringB, insert, remove, update);
#
# @see Levenshtein, Vladimir I. "Binary codes capable of correcting deletions,
# insertions and reversals." Soviet physics doklady. Vol. 10. 1966.
# @see Wagner, Robert A., and Michael J. Fischer. "The string-to-string 
# correction problem." Journal of the ACM (JACM) 21.1 (1974): 168-173.
#
levenshtein = (stringA, stringB, insertCb, removeCb, updateCb) ->
	a = stringA
	b = stringB

	dist = fill a.length + 1, b.length + 1, 0
	track = fill a.length + 1, b.length + 1, -1
	for i in [1..a.length] by 1
		dist[i][0] = i
	for j in [1..b.length] by 1
		dist[0][j] = j

	for i in [1..a.length] by 1
		for j in [1..b.length] by 1
			aC = a.charAt(i - 1)
			bC = b.charAt(j - 1)
			min = trackedMin(
				 dist[i - 1][j] + removeCb(aC),
				 dist[i][j - 1] + insertCb(bC),
				 dist[i - 1][j - 1] + updateCb(aC, bC))
			dist[i][j] = min.value
			track[i][j] = min.index

	return {
		distance: dist[a.length][b.length]
		alignment: alignment(a, b, track)
	}

#
# Computes the string alignment and mapping
#
alignment = (a, b, track) -> () ->
	mapping = []
	alignmentA = []
	alignmentB = []
	# Backtrack solution from lower right to upper left.
	i = a.length
	j = b.length
	while i > 0 and j > 0
		switch track[i][j]
			when 0
				# Remove
				mapping.push [a[i - 1], null]
				alignmentA[i - 1] = null
				--i
			when 1
				 # Insert
				mapping.push [null, b[j - 1]]
				alignmentB[j - 1] = null
				--j
			when 2 
				# Update
				mapping.push [a[i - 1], b[j - 1]]
				alignmentA[i - 1] = b[j - 1]
				alignmentB[j - 1] = a[i - 1]
				--i
				--j
			else
				throw new Error "Invalid operation #{track[i][j]} at (#{i}, #{j})"
	return {
		mapping: mapping,
		alignmentA: alignmentA
		alignmentB: alignmentB
	}

module.exports = levenshtein
