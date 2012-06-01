(function() {
  var dataStructures;

  dataStructures = module.exports = {
    node: function(data) {
      this.data = data;
      this.previous = null;
      return this.next = null;
    },
    linkedList: function() {
      var first, last;
      first = null;
      last = null;
      this.getFirst = function() {
        return first;
      };
      this.getLast = function() {
        return last;
      };
      this.insertFirst = function(value) {
        var newNode;
        newNode = new dataStructures.node(value);
        if (first === null) {
          last = newNode;
        } else {
          first.previous = newNode;
          newNode.next = first;
        }
        return first = newNode;
      };
      this.insertLast = function(value) {
        var newNode;
        newNode = new dataStructures.node(value);
        if (last === null) {
          first = newNode;
        } else {
          last.next = newNode;
          newNode.previous = last;
        }
        return last = newNode;
      };
      this.deleteFirst = function() {
        if (first === null) {
          return false;
        } else {
          if (first.next === null) {
            last = null;
          } else {
            first.next.previous = null;
          }
          first = first.next;
          return true;
        }
      };
      this.deleteLast = function() {
        if (last === null) {
          return false;
        } else {
          if (first.next === null) {
            first = null;
          } else {
            last.previous.next = null;
          }
          last = last.previous;
          return true;
        }
      };
      this.insertAfter = function(key, value) {
        var current, newNode;
        if (first === null) return false;
        current = first;
        while (current.data !== key) {
          current = current.next;
          if (current === null) return false;
        }
        newNode = new dataStructures.node(value);
        if (current === last) {
          newNode.next = null;
          last = newNode;
        } else {
          newNode.next = current.next;
          current.next.previous = newNode;
        }
        newNode.previous = current;
        current.next = newNode;
        return true;
      };
      this.deleteKey = function(key) {
        var current;
        if (first === null) return false;
        current = first;
        while (current.data !== key) {
          current = current.next;
          if (current === null) return false;
        }
        if (current === first) {
          first = current.next;
        } else {
          current.previous.next = current.next;
        }
        if (current === last) {
          last = current.previous;
        } else {
          current.next.previous = current.previous;
        }
        return true;
      };
      this.traverseForwards = function(callback) {
        var current, _results;
        current = first;
        _results = [];
        while (current) {
          callback(current);
          _results.push(current = current.next);
        }
        return _results;
      };
      return this.traverseBackwards = function(callback) {
        var current, _results;
        current = last;
        _results = [];
        while (current) {
          callback(current);
          _results.push(current = current.previous);
        }
        return _results;
      };
    },
    stack: function() {
      var elements;
      elements = [];
      this.push = function(element) {
        if (typeof elements === "undefined") elements = [];
        return elements.push(element);
      };
      this.pop = function() {
        return elements.pop();
      };
      this.stackTop = function(element) {
        return elements[elements.length - 1];
      };
      return this.length = function() {
        return elements.length;
      };
    },
    queue: function() {
      var elements;
      elements = void 0;
      this.enqueue = function(element) {
        if (typeof elements === "undefined") elements = [];
        return elements.push(element);
      };
      this.dequeue = function() {
        return elements.shift();
      };
      return this.peek = function() {
        return elements[0];
      };
    }
  };

}).call(this);
