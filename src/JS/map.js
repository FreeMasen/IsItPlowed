var map;
function initMap() {
    map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: 0.0, lng: 0.0},
        zoom: 12,
        disableDefaultUI: true
    });
};

function getLocation(address) {
    var url = "/api/area/test/lookup.json"
    var search = {
        q: address
    };
    $.getJSON(url, search)
        .done(function( json ){
            map = initMap($('#map').get(0), json['point'])
        })
        .fail(function (jqxr, textStatus, error ){
            console.log(error);
        });
};

function getRouteData(routeId) {
    var url = "http://ec2-54-183-243-1.us-west-1.compute.amazonaws.com:8080/api/county/scott/lookup.json?"
    var search = {
        q: routeId
    }
    $.getJSON(url, search)
        .done(function ( json ){
            console.log(json)
        })
        .fail(function(jqxr, textStatus, error){
            console.log(textStatus)
        })
};

$(function () {
    $("#search").on("click", function() {

    })
})

$(document).ready(function() {
    initMap();
    getLocation("found-one")
})