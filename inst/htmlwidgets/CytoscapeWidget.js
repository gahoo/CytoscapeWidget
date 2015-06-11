HTMLWidgets.widget({

  name: 'CytoscapeWidget',

  type: 'output',

  initialize: function(el, width, height) {
    var cy = cytoscape({
      container: document.getElementById(el.id)
    });

    return {
      // TODO: add instance fields as required
      cy: cy
    };

  },

  renderValue: function(el, x, instance) {

  var cy = cytoscape({
    container: document.getElementById(el.id),
    elements: x.options.elements
  });
    // el.innerText = x.message;

  },

  resize: function(el, width, height, instance) {

  }

});
