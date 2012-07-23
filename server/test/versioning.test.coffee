compare_versions = require('../labs/versioning').compare_versions

describe 'Labs Versioning', ->
  it 'should 0.0.2 > 0.0.1', ->
    val = compare_versions '0.0.2', '0.0.1'
    val.should.eql 1
    
  it 'should 0.0.1 < 0.0.2', ->
    val = compare_versions '0.0.1', '0.0.2'
    val.should.eql -1
  
  it 'should 0.1.1 > 0.0.3', ->
    val = compare_versions '0.1.1', '0.0.3'
    val.should.eql 1
    
  it 'should 1.2.3 < 4.3.4', ->
    val = compare_versions '1.2.3', '4.3.4'
    val.should.eql -1
  
  it 'should 1.1.1 > 1.1.1.beta', ->
    val = compare_versions '1.1.1', '1.1.1.beta'
    val.should.eql 1
  
  it 'should 1.1.1.beta > 1.1.1.alpha', ->
    val = compare_versions '1.1.1.beta', '1.1.1.alpha'
    val.should.eql 1
  
  it 'should 1.1.1.alpha < 1.1.1.Beta', ->
    val = compare_versions '1.1.1.alpha', '1.1.1.Beta'
    val.should.eql -1
  
  it 'should 1.2.3.rc > 1.2.3.beta', ->
    val = compare_versions '1.2.3.rc', '1.2.3.beta'
    val.should.eql 1
    
  it 'should 4.0.1 > 4.0.1.RC', ->
    val = compare_versions '4.0.1', '4.0.1.RC'
    val.should.eql 1
    
  it 'should 4 < 4.0.1.RC', ->
    val = compare_versions '4', '4.0.1.RC'
    val.should.eql -1
    
  it 'should 4 == 4.0.0', ->
    val = compare_versions '4', '4.0.0'
    val.should.eql 0
    
  it 'should 1.0.0.ALPha == 1.0.0.alpha', ->
    val = compare_versions '1.0.0.ALPha', '1.0.0.alpha'
    val.should.eql 0
    