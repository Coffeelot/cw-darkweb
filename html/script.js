let CWLaptop = {}
let Ads = []

let currentAd = {}
let currentAdId = -1

$(document).ready(function(){
    console.log('lol')
    $('.laptop-container').hide();

    window.addEventListener('message', function(event){
        var eventData = event.data;
        console.log(eventData.action)

        if (eventData.action == "cwLaptop") {
            if (eventData.toggle) {
                CWLaptop.Open()
            }
        }
    });
});

function handleConfirm() {
    console.log('confirmed', currentAd.title)
    if(currentAd){
        $.post('https://cw-darkweb/confirmPurchase', JSON.stringify(currentAd), function(wentThrough){
            console.log('aaa', wentThrough)

            if (wentThrough) {
                console.log(currentAd.name)
                $.post('https://cw-darkweb/removeAd', JSON.stringify(currentAd.name));
                $(".confirmation-box").hide('')
                $(`#${currentAd.name}${currentAdId}`).hide('')
            }
        });
    }
}

function handleClickToken(adName, index) {
    console.log('click', JSON.stringify(adName))
    $(".confirmation-box").html("");
    $(".confirmation-box").show("");
    let ad = Ads.find(ad => ad.name===adName)
    if(ad) {
        currentAd = ad;
        currentAdId = index;
        console.log('found ad!', ad.title)
        let element = `
        <div id="${adName}-confirmation" class="confirmation-card">
            <div class="card-header">
                Confirm Purchase of ${ad.title} for ${ad.price}
            </div>
            <div class="confirmation-card-body">
                <div class="confirm-button" onClick="handleConfirm()"> BUY </div>
            </div>
        </div>
        `;
        $(".confirmation-box").append(element);

    } else {
        console.log('something went wrong')
    }

}

let LoadAds = function() {
    Ads = Ads.reverse();

    if (Ads !== null && Ads !== undefined && Ads !== "" && Ads.length > 0) {
        $(".darkweb-items").html("");
        $(".confirmation-box").html("");
        currentAd = {}

        $.each(Ads, function(i, Ad) {

            let type = Ad.type;
            let title = Ad.title;
            let body = Ad.body;
            let footer = Ad.footer;
            let price = Ad.price;
            let name = Ad.name;

            if (type === 'token') {
                let element = `
                    <div id="${name}${i}" class="card" onclick="handleClickToken('${name}', '${i}')">
                        <div class="card-header">
                            ${title} | ${price}
                        </div>
                        <div class="card-body">
                            ${body}
                        </div>
                        <div class="card-footer">
                            ${footer}
                        </div>
                    </div>
                    `;
                $(".darkweb-items").append(element);
            }
        });
    }
}

CWLaptop.Open = function() {
    console.log('opening dw')
    $.post('https://cw-darkweb/checkIfPlayerHasCWLaptop', function(hasItem){
        if (hasItem) {
            $.post('https://cw-darkweb/generateAds', function(ads){
                if (ads) {
                    console.log('ads', JSON.stringify(ads))
                    Ads = ads;
                    $('.laptop-container').fadeIn(250);
                    LoadAds();
                }
            })
        }
    })
}

CWLaptop.Close = function() {
    $('.laptop-container').fadeOut(250);
    $.post('https://cw-darkweb/exitCWLaptop');
}

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27:
            CWLaptop.Close();
            break;
    }
});