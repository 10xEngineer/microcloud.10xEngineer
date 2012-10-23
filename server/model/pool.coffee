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

  disabled: {type: Boolean, default: false}

  # TODO statistics fields
  statistics: {

  }

Pool.plugin timestamps

Pool.statics.find_by_name = (name, callback) ->
	mongoose.model('Pool')
		.findOne({name: name})
		.exec(callback)

module.exports.register = mongoose.model 'Pool', Pool