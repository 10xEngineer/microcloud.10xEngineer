# labs/versioning.coffee
module.exports = ->

# TODO function/class to get major/minor/build

module.exports.compare_versions = (ver1, ver2) ->
	# major.minor.build[.status] 
	# status = {alpha, beta, rc}
	# 0.0.2 > 0.0.1
	# 0.1.1 > 0.0.3
	# 1.2.3 > 4.3.4
	# 1.1.1 > 1.1.1.beta
	# 1.1.1.beta > 1.1.1.alpha
	# 1.2.3.rc > 1.2.3.beta

	# 0 ==
	# 1 a > b
	# -1 a < b


