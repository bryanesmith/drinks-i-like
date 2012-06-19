$(document).ready( function() {

  // >>>>>>>>>> MODEL <<<<<<<<<<
  var Drink = Backbone.Model.extend({});

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
      //'click #add-drink' : 'addDrink',
      'click .remove-drink' : 'removeDrink',
    },

    initialize: function() {
      var that = this;
      
      // Bind events to collection
      //this.collection.bind('add', this.add);
      //this.collection.bind('remove', this.remove);

      // Grab template
      this.template =  $.template(this.templateId);

      // Render
      this.render();
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

      var that = this;
      var coll = this.collection;

      _(coll.models).each(function(drink) {
        var drinkName = drink.get('title');
        var rowDrinkName = $(ev.currentTarget).parent().parent().find('.title').attr('id');

        if ( drinkName === rowDrinkName ) {
          coll.remove( drink );
        } 

      });

      // TODO: Use events to call render instead
      this.render();

      return false;
    }
  });

  // >>>>>>>>>> GO! <<<<<<<<<

  // Grab drinks from server
  drinks.fetch({
    success: function() {
      drinks.each(function(drink) {
        console.log( drink.get("title") );
      });

      var drinksView = new DrinksView( { collection: drinks } );
    } // success
  });

});
