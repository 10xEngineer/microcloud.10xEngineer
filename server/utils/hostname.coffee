log 		= require("log4js").getLogger()

nouns = [
	'monster','moon','star','sea','shadow','cloud','leaf','dawn','bird','dust','field',
	'fire','pond','sky','thunder','sun','fog','smoke','merlin','base','bot','octopus',
	'nova','fusion','orion','nexus','fenix','nitro','hydra','pixie','sparky','pluto',
	'luna','eve','buzz','helix','ceres','sirius','brick','sol','gibbon','dragon', 'falcon',
	'frog','goose','lemur','lion','monk','pony','snail','spaceship','gargoyle','spider','cat',
	'dog','mouse','planet','robot','crow','kitten','snake','reactor','atom','comet','wizard','fairy',
	'goblin','troll','asteroid','meteor','book','library','galaxy','cluster','castle','fireball',
	'maniac','pumpkin','shoe','slipper','carriage','goblin','field','horizon','ocean','landscape',
	'bat','lab','insect','orangutang','bacteria','workshop','egg','airplane','ship','planet']

adjs = [
	'bitter','silent','dark','icy','cool','white','blue','green','bold','red','frosty',
	'proud','strong','good','busy','cold','crazy','plain','misty','clean','angry','cruel',
	'mad','brave','jolly','loud','soft','fresh','spicy','solid','magical','magic','warm',
	'opaque','purple','happy','genius','daring','cautious','methodical','manic','brilliant',
	'yellow','pink','black','pumpkin','spooky','sad','scary','distant','noisy','opaque']

random = (limit) ->
	return Math.floor(Math.random() * limit)

class NameGenerator
	instance: null

	constructor: () ->
		@dictionaries = [this.select(adjs), this.select(nouns)]

	choose: () ->
		output = []

		for func in @dictionaries
			output.push(func())

		return output.join('-')

	select: (dictionary) ->
		return () -> 
			return dictionary[random(dictionary.length)]

	@getInstance: () ->
		unless @instance
			@instance = new NameGenerator()

		return @instance

module.exports.NameGenerator = NameGenerator

module.exports.generate = () ->
	generator = NameGenerator.getInstance()
	generator.choose()
