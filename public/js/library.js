$(document).ready( function() {

  // >>>>>>>>>> MODEL <<<<<<<<<<
  var Drink = Backbone.Model.extend({
    urlRoot: '/api/drink'
  });

  // >>>>>>>>>> COLLECTION <<<<<<<<<<
  var DrinkCollection = Backbone.Collection.extend({
    model:Drink,
    url: '/api/drink'
  });

  // >>>>>>>>>> VIEWS <<<<<<<<<<
  var drinks = new DrinkCollection();

  // ----- DrinksView -----
  var DrinksView = Backbone.View.extend({
    el: $('#drinks'),
    templateId: '#drinks-template',

    events: {
      'click .remove-drink' : 'removeDrink',
      'change .title' : 'updateTitle',
      'change .description' : 'updateDescription'
    },

    initialize: function() {

      // Bind events to collection
      this.collection.bind('add', this.render, this);
      this.collection.bind('remove', this.render, this);

      // Grab template
      this.template =  $.template(this.templateId);

      // Render
      this.render();
    },

    updateTitle: function(ev) {
      var options = { title: $(ev.currentTarget).val() };
      find_and_update_drink( ev, this, options );
    },

    updateDescription: function(ev) {
      var options = { description: $(ev.currentTarget).val() };
      find_and_update_drink( ev, this, options );
    },

    render: function() {
      var that = this;

      $(this.el).find('td').remove();

      // Render each drink
      _(this.collection.models).each(function(drink) {
        $.tmpl(that.template, drink.toJSON()).appendTo(that.el);
      });
    },

    removeDrink: function(ev) {

      var coll = this.collection;

      var drinkId = $(ev.currentTarget).parent().parent().find('.id').val();
      var drink = find_matching_drink(coll.models, drinkId);

      if ( drink ) {
        drink.destroy({
          success: function(model, response) { coll.remove( drink ); },
          error:   function() { alert( "Could not remove drink: " + drink.get('title') )}
        });
      } else {
        alert( 'Cannot remove drink: no drink with id = ' + id );
      }

      return false;

    },

  });

  // >>>>>>>>>> GO! <<<<<<<<<

  // Grab drinks from server
  drinks.fetch({
    success: function() {
      var drinksView = new DrinksView( { collection: drinks } );
    } // success
  });

  // Attach to button
  $('#add-drink').click(function () {

    var title = $('#add-title').val();
    var desc  = $('#add-description').val();

    var drink = new Drink({
      title: title,
      description: desc
    });

    // Reset form
    $('#new-drink').each (function(){
      this.reset();
    });

    drink.save({wait: true});

    drink.fetch({
      success: function() {
        drinks.add(drink);
      }
    });

    return false;
  });

});

/**
 * Helper function to find the modified drink and save the changes
 */
function find_and_update_drink( event, drinksView, newValues ) {

  var drinks  = drinksView.collection.models;
  var drinkId = $(event.currentTarget).parent().parent().find('.id').val();
  var drink   = find_matching_drink( drinks, drinkId );

  if ( drink ) {
    drink.set(newValues);
    drink.save({wait: true});
    drinksView.collection.fetch(); // Update collection
  } else {
    alert( "Didn't find drink with id = " + drinkId );
  }

}

/**
 * Helper function to find a drink in an array using its id.
 */
function find_matching_drink(drinks, id) {

  var drink = null;
  _(drinks).each(function(thisDrink) {

    // Find the matching drink
    var thisDrinkID = thisDrink.get('id');

    if ( thisDrinkID == id ) {
      drink =  thisDrink;
    } 

  });

  return drink;

}

