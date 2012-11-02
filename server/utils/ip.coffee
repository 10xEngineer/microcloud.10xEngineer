# generates random IP address

generateIP = () ->
	prefix = 172
	segment_ranges = [0,14,253,253]
	segment_initial = [172, 17, 1, 1]

	ip_data = []

	for index in [0..(segment_ranges.length-1)]
		rand = Math.floor(Math.random()*segment_ranges[index])

		initial = segment_initial[index]

		ip_data.push((initial + rand))

	return ip_data.join('.')

module.exports.generate = generateIP