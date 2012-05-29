(function() {

  define(function() {
    var AllocationPool, borrowItem, recycle;
    return sp.Class.create("AllocationPool", {
      constructor: AllocationPool = function(klass, maxSize) {
        this.klass = klass;
        this.maxSize = maxSize || 100;
        return this.pool = [];
      },
      properties: {
        klass: null,
        maxSize: 100,
        pool: null
      },
      methods: {
        borrowItem: borrowItem = function() {
          if (this.pool.length > 0) {
            return this.pool.pop();
          } else {
            return new this.klass();
          }
        },
        recycle: recycle = function(item) {
          if (this.pool.length < this.maxSize) return this.pool.push(item);
        }
      }
    });
  });

}).call(this);
