(function() {
  var HashTable;

  HashTable = (function() {

    function HashTable() {
      this.length = 0;
      this.items = {};
    }

    HashTable.prototype.size = function() {
      return this.length;
    };

    HashTable.prototype.setItem = function(key, value) {
      var previous;
      previous = null;
      if (this.hasItem(key)) {
        previous = this.items[key];
      } else {
        this.length++;
      }
      this.items[key] = value;
      return previous;
    };

    HashTable.prototype.getItem = function(key) {
      if (this.hasItem(key)) {
        return this.items[key];
      } else {
        return null;
      }
    };

    HashTable.prototype.hasItem = function(key) {
      return this.items.hasOwnProperty(key);
    };

    HashTable.prototype.removeItem = function(key) {
      var previous;
      if (this.hasItem(key)) {
        previous = this.items[key];
        this.length--;
        delete this.items[key];
        return previous;
      } else {
        return null;
      }
    };

    HashTable.prototype.keys = function() {
      var k, keys;
      keys = [];
      for (k in this.items) {
        if (this.hasItem(k)) keys.push(k);
      }
      return keys;
    };

    HashTable.prototype.values = function() {
      var k, values;
      values = [];
      for (k in this.items) {
        if (this.hasItem(k)) values.push(this.items[k]);
      }
      return values;
    };

    HashTable.prototype.each = function(fn) {
      var k, _results;
      _results = [];
      for (k in this.items) {
        if (this.hasItem(k)) {
          _results.push(fn(k, this.items[k]));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    HashTable.prototype.clear = function() {
      this.items = {};
      return this.length = 0;
    };

    return HashTable;

  })();

  module.exports = HashTable;

}).call(this);
