var map;

window.initMap = function () {
    map = new google.maps.Map(document.getElementById('map'), {
        center: {lat: 43, lng: -93},
        zoom: 15,
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
            snowEmergency(json)
            var latLng = json['point'];
            var center = new google.maps.LatLng(latLng["lat"], latLng["lng"]);
            window.map.panTo(center);
            var marker = new google.maps.Marker({
                position: window.map.center,
                map: window.map,
                title: address,
                label: "H"
            });
            console.log(json)
            getRouteData(json["snow_emergency"]['route_id'], json['id'])
        })
        .fail(function (jqxr, textStatus, error ){
            console.log(error + " " + error);
        });
};

function snowEmergency(json) {
    var snowEmergency = json['snow_emergency']['active'];
    if (snowEmergency == 1) {
        $("#currentStatus").html("Snow emergency has been declared!");
        $('#currentStatus').css('padding-left', '5px')
        $("#indicator").css('color', 'red')
    };
};

function getRouteData(routeId, placeId) {
    var url = "/api/area/test/route.json"
    var search = {
        route_id: routeId
    }
    $.getJSON(url, search)
        .done(function ( json ){
            var jsonCoords = json["geometry"];
            console.log(json)
            var polyLine = new google.maps.Polyline({
                path: jsonCoords,
                geodesc: true,
                strokeColor: '#FF0000',
                strokeOpacity: 1.0,
                strokeWeight: 2,
                map: window.map
            });
            var completeCoords = new google.maps.Polyline( {
                path: [
                    jsonCoords[0],
                    {lat: 44.759379, lng: -93.402525},
                    {lat:44.757665, lng:-93.404982}
                ],
                geodesc: true,
                strokeColor: 'green',
                strokeOpacity: 1.0,
                strokeWeight: 2,
                map: window.map
            })
            var lat = json["current_info"]["point"]["lat"];
            var lng = json["current_info"]["point"]["lng"];
            var latlng = new google.maps.LatLng(lat, lng)
            var plowMarker = new google.maps.Marker( {
                position: jsonCoords[0],
                map: window.map,
                icon: "/blue_MarkerP.png"
            })

        })
        .fail(function(jqxr, textStatus, error){
            console.log(textStatus + ": " + error)
        })
};



$(document).ready(function() {
    window.initMap();
    $("#search").on("click", function() {
        window.getLocation('found-one');
    });
})