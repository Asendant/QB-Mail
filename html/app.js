let maximumPackages = 20;

$(document).ready(function () {
    $('.container').hide();

    window.addEventListener('message', function (event) {
        let data = event.data;

        if (data.type === "ui") {
            if (data.display === true) {
                $('.container').show();
            } else {
                $('.container').hide();
            }
        }
    });

    $('#submit').click(function () {
        GetSubmittedAmount();
    })
})

function GetSubmittedAmount() {
    let value = parseInt(document.getElementById('packageAmount').value);

    if (value <= 0 || value > maximumPackages) {
        $.post(`https://${GetParentResourceName()}/error`, JSON.stringify({
            error: `Invalid Input.  Needs to be between 1 and ${maximumPackages}`
        }))

        return;
    }

    $('.container').hide();

    $.post(`https://${GetParentResourceName()}/setPackageAmount`, JSON.stringify({
        amount: value
    }))

    return;
}
