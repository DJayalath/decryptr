// Primary Site Scripts

function show(shown, hidden) // Show or hide divs by ID
{
    document.getElementById(shown).style.display='block';
    document.getElementById(hidden).style.display='none';
    return false;
}

function onload() // Restore saved settings on load
{
    var status = localStorage.getItem("cipher_type");
    if (status == "1")
    {
        document.getElementById("Caesar").checked = true;
    } else if (status == "2")
    {
        document.getElementById("Vigenere").checked = true;
    } else if (status == "3")
    {
        document.getElementById("Substitution").checked = true;
    } else if (status == "4")
    {
        document.getElementById("Beaufort").checked = true;
    } else if (status == "5")
    {
        document.getElementById("Hill").checked = true;
    } else
    {
        document.getElementById("Caesar").checked = true;
    }
    
    var matrix_status = localStorage.getItem("matrix_type");
    if (matrix_status == "3")
    {
        document.getElementById("s-option").checked = true;
    } else
    {
        document.getElementById("f-option").checked = true;
    }
    
    var slider_pos = localStorage.getItem("slider_status");
    var output = document.getElementById("demo");
    if (slider_pos != null)
    {
        document.getElementById('myRange').value = slider_pos;
        output.innerHTML = slider_pos;
    } else
    {
        document.getElementById('myRange').value = 15;
        output.innerHTML = slider_pos;
    }
    
}

//document.getElementById("subButton").addEventListener("click", decrypt_click);

function decrypt_click() // Start pulse animation and clear decrypted textarea box
{
    animation()
    var textboxes = document.getElementsByClassName('inputbox');
    textboxes[1].value = '';
}

function save_cipher(type) // Save cipher setting
{
    localStorage.setItem("cipher_type", type);
}

function save_matrix(type) // Save matrix dimension setting
{
    localStorage.setItem("matrix_type", type);
}

function save_slider(val) // Save slider setting
{
    localStorage.setItem("slider_status", val);
}

function animation() // Pulsing animation
{
    document.getElementById("output").style.WebkitAnimationPlayState = "running";
}

function stop_animation() // Stop pulsing
{
    document.getElementById("output").style.WebkitAnimationPlayState = "paused";
}

// Modal Scripts

// Get the modal
var modal = document.getElementById('myModal');

// Get the button that opens the modal
var btn = document.getElementById("myBtn");

// Get the <span> element that closes the modal
var span = document.getElementsByClassName("close")[0];

// When the user clicks the button, open the modal 
btn.onclick = function() {
    modal.style.display = "block";
}

// When the user clicks on <span> (x), close the modal
span.onclick = function() {
    modal.style.display = "none";
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
    if (event.target == modal) {
        modal.style.display = "none";
    }
}

// Slider Scripts

var slider = document.getElementById("myRange");
var output = document.getElementById("demo");
output.innerHTML = slider.value;

slider.oninput = function() {
  output.innerHTML = this.value;
}