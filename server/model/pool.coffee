log = require("log4js").getLogger()
mongoose	= require 'mongoose'
Schema		= mongoose.Schema
ObjectId	= Schema.ObjectId

timestamps	= require "../utility/timestamp_plugin"

ActiveNodes = new Schema
	hostname: String
	node_ref: ObjectId

Pool = new Schema
  name: {type: String, unique: true}
  nodes: [ActiveNodes]

  allocation: String

  disabled: {type: Boolean, default: false}

  # TODO statistics fields
  statistics: {

  }

Pool.plugin timestamps

Pool.statics.find_by_name = (name, callback) ->
	mongoose.model('Pool')
		.findOne({name: name})
		.exec(callback)

Pool.methods.selectNode = (callback) ->
  # TODO use allocation strategy to select the node
  #
  # - LRU
  # - Activity Based - need scoring of provisioning/housekeeping 
  #   activity and select the the node with least activity
  #
  # For now using random selection
  node_index = Math.floor(Math.random()*(new Date().getTime()) % this.nodes.length)

  callback(null, this.nodes[node_index].hostname)

module.exports.register = mongoose.model 'Pool', Pool