/**
 * To move around the image on click.
 */
(function() {
    "use strict";

    var element = document.getElementById("image");

    element.addEventListener("click", function() {
        var style = window.getComputedStyle(element);
        var rotation = style.getPropertyValue("transform");

        console.log(rotation);
        if (rotation === "matrix(-1, 0, 0, -1, 0, 0)") {
            rotation = "matrix(1, 0, 0, 1, 0, 0)";
        } else {
            rotation = "matrix(-1, 0, 0, -1, 0, 0)";
        }

        element.style.transform = rotation;

        console.log("Image was clicked");
        console.log(rotation);
    });

}());
