/**
 * Handle the Submit click from index.html. changeUpper reads the textarea
 * with id "entry" and replaces its value with the uppercase text in place.
 * The input stays in the browser.
 */
function changeUpper() {
    let input = document.getElementById("entry").value;
    document.getElementById("entry").value = input.toUpperCase();
}
