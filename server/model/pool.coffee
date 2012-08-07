log = require("log4js").getLogger()

mongoose  = require 'mongoose'
Schema    = mongoose.Schema
Vm        = mongoose.model("Vm")

timestamps    = require "../utility/timestamp_plugin"
uniqueness    = require "../utility/uniquenessPlugin"
stateMachine  = require "../utility/state_plugin"

Pool = new Schema
  name: {type: String, unique: true}
  environment: String
  vm_type: String
  # TODO owner

Pool.plugin timestamps

Pool.methods.getStatistics = (next) ->
	# FIXME map/reduce must be used in sharded MongoDB deployment
	reduce = (doc, out) ->
		out.count++

	finalize = (out) ->

	Vm.collection.group {server:1}, {pool: this._id}, {count: 0}, reduce, finalize, (err, res) =>
		next null, this, res

module.exports.schema = Pool
module.exports.register = mongoose.model 'Pool', Pool
