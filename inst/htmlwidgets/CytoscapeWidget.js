HTMLWidgets.widget({

  name: 'CytoscapeWidget',

  type: 'output',

  renderValue: function(el, options, instance) {

    options['container'] = document.getElementById(el.id);
    var cy = cytoscape(options);

  },

  resize: function(el, width, height, instance) {
    var cy = document.getElementById(el.id).cytoscape('get');
    cy.resize();
  }

});
