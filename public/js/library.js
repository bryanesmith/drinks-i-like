$(document).ready( function() {
  var Drink = Backbone.Model.extend({});

  var DrinkCollection = Backbone.Collection.extend({
    model:Drink,
    url: '/api/drink'
  });

  var drinks = new DrinkCollection();

  drinks.fetch({
    success: function() {
                drinks.each(function(drink) {
                  console.log( drink.get("title") );
                });

                var thaiTea = new Drink({
                  title: 'Thai Iced Tea',
                  description: 'A sweet, orange-colored tea from Thailand.',
                });

                drinks.on("add", function(drink) {
                  console.log("Added drink: " + drink.get("title") );
                });

                drinks.on("sync", function(drink) {
                  console.log("Syncing with server" );
                });

                drinks.create({
                  title: 'Thai Iced Tea',
                  description: 'A sweet, orange-colored tea from Thailand.',
                });
              }
  });

});
