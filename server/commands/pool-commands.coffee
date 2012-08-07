mongoose= require 'mongoose'
Pool    = mongoose.model 'Pool'
Vm      = mongoose.model 'Vm'
Hostnode= mongoose.model 'Hostnode'
Lab     = mongoose.model 'Lab'
broker  = require("../broker")
config  = require '../config'

async   = require 'async'
http    = require 'http'
_       = require 'underscore'
log     = require('log4js').getLogger()

helper  = require './helper'

module.exports.create = (req, res, next) ->
  data = JSON.parse req.body
  helper.load data

  async.waterfall [
    (next) -> helper.checkPresenceOf ["name", "environment", "vm_type"], next
   ,(next) ->
      pool = new Pool(data)
      pool.save (err) ->
        if err
          next 
            msg : "Unable to save pool: #{err.message}"
            code: 500
        else next null, pool
  ], (err, pool) ->
    if err
      return helper.handleErr res, err

    log.info "pool=#{pool.name} saved"
    res.send pool

module.exports.destroy = (req, res, next) ->
  res.send 500, "pool::destroy NOT IMPLEMENTED"

module.exports.addserver = (req, res, next) ->
  data = JSON.parse req.body
  Pool.findOne name: poolName = req.params.pool, (err, pool) ->
    if err
      return helper.handleErr res, err
    unless pool then return helper.handleErr res, 
      msg: "No such Pool with name '#{poolName}' found"
      code: 404
    Hostnode.findOne server_id: server_id = data.server_id, (err, hostnode) ->
      if err
        return helper.handleErr res, err
      unless hostnode then return helper.handleErr res, 
        msg: "No such hostnode with server_id '#{server_id}' found"
        code: 404

      if hostnode.pool?
        return helper.handleErr res, 
          msg: "Hostnode '#{server_id}' already assigned to a pool."
          code: 409

      hostnode.pool = pool
      hostnode.save (err) ->
        log.info "hostnode=#{server_id} added to pool=#{pool.name}"
        res.send 200

module.exports.removeserver = (req, res, next) ->
  # TODO remove pool from hostnode definition
  # TODO what to do with allocated VMs?
  # TODO trigger workflow particulary for this workflow
  res.send 500, "pool::removeserver NOT IMPLEMENTED"

module.exports.get = (req, res, next) ->
  async.waterfall [
     (next) ->
      Pool.findOne name: req.params.pool, (err, pool) ->
        if err
          return next 
            msg : "Unable to get pool: #{err.message}"
            code: 500

        unless pool
          return next 
            msg : "pool=#{req.params.pool} not found."
            code: 404

        pool.getStatistics(next)
    ], (err, pool, nodes) ->
      if err
        return helper.handleErr res, err

      total = 0
      for node in nodes
        total = node.count

      pool_data =
        name: pool.name
        environment: pool.environment
        vm_type: pool.vm_type
        total: total
        statistics: nodes

      res.send pool_data

module.exports.allocate = (req, res, next) ->
  # TODO get VMs (lock), or fail
  # TODO dispatch allocate

  data = JSON.parse req.body
  helper.load data

  checkParams = (next) ->
    helper.checkPresenceOf ["lab", "vm"], next

  findPool = ['checkParams', (next) ->
    Pool.findOne name: poolName = req.params.pool, (err, pool) ->
      unless pool then next
        msg: "pool='#{poolName}' not found"
        code: 404
      else 
        next null, pool
  ]

  getLab = ['findPool', (next) ->
    Lab.findOne name: data.lab, (err, lab) ->
      unless lab then next
        msg: "No lab with name '#{data.lab}'."
        code: 500
      else
        next null, lab
  ]

  getVM = ['getLab', (next, results) -> 
    # TODO pluggable strategy how to select appropriate hostnode
    # https://trello.com/card/pool-allocation-strategies/50067c2712a969ae032917f4/34
    vm = data.vm

    query = 
      state: 'prepared'
      pool: results.findPool._id

    Vm.findAndModify query, [], {$set: {state: 'locked', lab: results.getLab._id, vm_name: vm.name}}, {}, (err, vm) ->
      unless vm then next
        msg: "No prepared VM available (#{err})"
        code: 406
      else
        next null, vm
  ]

  async.auto
    checkParams: checkParams
    findPool: findPool
    getLab: getLab
    getVM: getVM
  , (err, results) ->
    if err
      helper.handleErr res, err
    else
      vm = 
        uuid: results.getVM.uuid
        meta: results.getVM.meta
        server:
          server_id: results.getVM.server.server_id
        state: results.getVM.state
        vm_type: results.getVM.vm_type

      res.send 200, vm

module.exports.deallocate = (req, res, next) ->
  res.send 500, "pool::deallocate NOT IMPLEMENTED"