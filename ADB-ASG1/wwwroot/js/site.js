// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.
const APIKEY = '6382e824c890f30a8fd1f5ae'


var ccsBanner = setInterval(function () {
    if (sessionStorage.getItem("CustId") != null && sessionStorage.getItem("HasGenerated") == null) {
        if (isLastDayOfMonth(new Date(sessionStorage.getItem("CurrentDate"))) && sessionStorage.getItem("ObjId") != null) {
            const objId = sessionStorage.getItem("ObjId");
            const custId = sessionStorage.getItem("CustId");

            const jsondata = { "custId": custId, "hasNewCCS": true };
            let settings = {
                "async": true,
                "crossDomain": true,
                "url": "https://adbasg1-89bc.restdb.io/rest/adbcustomer/" + objId,
                "method": "PUT",
                "headers": {
                    "content-type": "application/json",
                    "x-apikey": APIKEY,
                    "cache-control": "no-cache"
                },
                "processData": false,
                "data": JSON.stringify(jsondata)
            }
            $.ajax(settings).done(function (response) {
                console.log(response);
            });
        }

        let settings = {
            "async": true,
            "crossDomain": true,
            "url": "https://adbasg1-89bc.restdb.io/rest/adbcustomer",
            "method": "GET",
            "headers": {
                "content-type": "application/json",
                "x-apikey": APIKEY,
                "cache-control": "no-cache"
            }
        }

        $.ajax(settings).done(function (response) {
            const customer = response.find(c => c.custId === sessionStorage.getItem('CustId'));

            if (sessionStorage.getItem("ObjId") != null)
                clearInterval(ccsBanner);

            sessionStorage.setItem("ObjId", customer._id);
            if (customer.hasNewCCS) {
                $("#monthlyCSSWrapper").toggle();
                sessionStorage.setItem("HasGenerated", "Yes");
            }
        });

    } else {
        getCustId();
        getCurrentDate();
    }
}, 2000)

function getCustId() {
    $.ajax({
        type: "POST",
        url: "/Home/AjaxCallSessionString",
        data: { "sessionName": "CustId" },
        success: function (response) {
            if (response != null) {
                sessionStorage.setItem("CustId", response);
            }
        }
    });
}

function getCurrentDate() {
    $.ajax({
        type: "POST",
        url: "/Home/AjaxCallSessionString",
        data: { "sessionName": "CurrentDate" },
        success: function (response) {
            if (response != null) {
                sessionStorage.setItem("CurrentDate", response);
            }
        }
    });
}

function isLastDayOfMonth(date = new Date()) {
    // 👇️              ms    sec  min   hour
    const oneDayInMs = 1000 * 60 * 60 * 24;

    return new Date(date.getTime() + oneDayInMs).getDate() === 1;
}

function closeBanner() {
    $("#monthlyCSSWrapper").toggle();
    const objId = sessionStorage.getItem("ObjId");
    const custId = sessionStorage.getItem("CustId");

    const jsondata = { "custId": custId, "hasNewCCS": false };
    let settings = {
        "async": true,
        "crossDomain": true,
        "url": "https://adbasg1-89bc.restdb.io/rest/adbcustomer/"+objId,
        "method": "PUT",
        "headers": {
            "content-type": "application/json",
            "x-apikey": APIKEY,
            "cache-control": "no-cache"
        },
        "processData": false,
        "data": JSON.stringify(jsondata)
    }

    $.ajax(settings).done(function (response) {
        console.log(response);
    });
}