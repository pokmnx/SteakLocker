Parse.initialize('MEhfCXacMGU4wU9R7GNImyxP8766VJwCpnvE4ctI', 'SVprGab75cmPyhK9zOovSU2wSrXdtShvMtQpHb1s', '26DUd04eEw6T9Xr5mvIfNFryniPUdrcsEGE26DAk');
Parse.serverURL = 'https://steaklocker.herokuapp.com/parse';



window.SL = {};


SL.QueryString = SL.QueryString || {};
SL.QueryString._data = false;
SL.QueryString.parse = function (queryString) {
    // if a query string wasn't specified, use the query string from the URL
    var values = {};
    if (queryString === undefined){
        queryString = location.search ? location.search : '';
    }

    // remove the leading question mark from the query string if it is present
    if (queryString.charAt(0) == '?') queryString = queryString.substring(1);

    // check whether the query string is empty
    if (queryString.length > 0){

        // replace plus signs in the query string with spaces
        queryString = queryString.replace(/\+/g, ' ');

        // split the query string around ampersands and semicolons
        var queryComponents = queryString.split(/[&;]/g);

        // loop over the query string components
        for (var index = 0; index < queryComponents.length; index ++){

            // extract this component's key-value pair
            var keyValuePair = queryComponents[index].split('=');
            var key          = decodeURIComponent(keyValuePair[0]);
            var value        = (keyValuePair.length > 1) ? decodeURIComponent(keyValuePair[1]) : '';

            // store the value
            values[key] = value;
        }
    }
    return values;
};

SL.QueryString.get = function(name) {
    if (!SL.QueryString._data) {
        SL.QueryString._data = SL.QueryString.parse();
    }
    if (SL.QueryString._data) {
        if (typeof(SL.QueryString._data[name]) != 'undefined') {
            return SL.QueryString._data[name];
        }
    }
    return false;
};




SL.templates = {};
SL.buttonWorking = function(btn, on) {
    var B = $(btn), text=B.data('text'), icon=B.data('icon'), textW=B.data('workingText'), iconW=B.data('workingIcon');

    if (on) {
        B.addClass('working');
        B.find('.fa').removeClass(icon).addClass(iconW);
        B.find('.text').html(textW);
    }
    else {
        B.removeClass('working');
        B.find('.fa').removeClass(iconW).addClass(icon);
        B.find('.text').html(text);
    }
};
SL.iconWorking = function(icon, on) {
    var I = $(icon), icon=I.data('icon'), iconW=I.data('workingIcon');

    if (on) {
        I.removeClass(icon).addClass(iconW);
    }
    else {
        I.removeClass(iconW).addClass(icon);
    }
};

SL.searchUsers = function(f) {
    var F = $(f);
    var searchValue = $('#search-value').val().trim(), searchField = $('#search-field').val();

    if (!F.hasClass('working') && searchValue != '') {
        F.addClass('working');
        SL.buttonWorking(F.find('.btn[type=submit]'), true);

        var query = new Parse.Query(Parse.User);
        query.matches(searchField, new RegExp(searchValue, 'i'));
        query.find({
            success: function (results) {

                var tpl, val = '';
                if (results.length == 0) {
                    tpl = SL.template('tpl-no-results');
                    try {
                        val += tpl({'query':searchValue});
                    }
                    catch (e) {
                        console.log(e);
                    }
                }
                else {
                    tpl = SL.template('tpl-user-row');
                    for (var i = 0; i < results.length; i++) {
                        try {
                            val += tpl(results[i].toJSON());
                        }
                        catch (e) {
                            console.log(e);
                        }
                    }
                }
                $('#results tbody').html(val);
                F.removeClass('working');
                SL.buttonWorking(F.find('.btn[type=submit]'), false);
            },
            error: function (error) {
                alert("Error: " + error.code + " " + error.message);
            }
        });
    }
    return false;
};

SL.activeUser = null;
SL.fetchUser  = function(objectId, callback)
{
    var query = new Parse.Query(Parse.User);
    query.equalTo('objectId', objectId)
    query.first({
        success: function(user) {
            SL.activeUser = user;
            if (typeof(callback) == 'function') {
                callback(user);
            }
        }
    });
};
SL.fetchDevices = function(userId, successCallback, errorCallback)
{
    var User   = Parse.User;
    var Device = Parse.Object.extend("Device");
    var query = new Parse.Query(Device);
    query.equalTo('user', new User({id: userId}));
    query.descending('createdAt');
    query.find({
        success: function(results) {
            var items = _.map(results, function(item){ return item.toJSON(); });
            if (typeof(successCallback) == 'function') { successCallback(items); }
        },
        error: function(error) {
            if (typeof(errorCallback) == 'function') { errorCallback(error); }
        }
    });
};

SL.removeDevice = function (userId, deviceId)
{
    var User   = Parse.User;
    var Device = Parse.Object.extend("Device");
    var query = new Parse.Query(Device);
    query.equalTo('user', new User({id: userId}));
    query.equalTo('objectId', deviceId);
    query.first({
        success: function(device) {
            var name = device.get('nickname') +" ("+device.id+")";
            if (confirm("Are you sure you want to delete '"+ name + "'?")) {
                device.destroy({
                    success: function(myObject) {
                        $('#device-'+device.id).html('<div class="alert alert-success">'+name +" deleted.</div>");
                    },
                    error: function(myObject, error) {
                        alert('Error removing device');
                    }
                });

            }
        },
        error: function(error) {
            alert('Error removing device');
        }
    });
    return false;
};

SL.enableCharcuterie = function(checkbox)
{
    var C = $(checkbox), I = $(C.data('statusIcon')), B = C.prop('checked');
    SL.iconWorking(I, true);
    if (SL.activeUser) {
        Parse.Cloud.run('modifyUser', {
            objectId: SL.activeUser.id,
            key: 'charcuterieEnabled',
            value: B
        }).then(function(result) {
            SL.iconWorking(I, false);
        }, function(error) {
            SL.iconWorking(I, false);
        });
    }
};

SL.enableProUser = function(checkbox)
{
    var C = $(checkbox), I = $(C.data('statusIcon')), B = C.prop('checked');
    SL.iconWorking(I, true);
    if (SL.activeUser) {
        Parse.Cloud.run('modifyUser', {
            objectId: SL.activeUser.id,
            key: 'isProUser',
            value: B
        }).then(function(result) {
            SL.iconWorking(I, false);
        }, function(error) {
            SL.iconWorking(I, false);
        });
    }
};

SL.showEditForm = function (key, editing)
{
    var P = $('#preview-'+key), F = $('#edit-'+key);
    if (editing) {
        P.addClass('hidden');
        F.removeClass('hidden');
    }
    else {
        P.removeClass('hidden');
        F.addClass('hidden');
    }
    return false;
};
SL.setEmail = function()
{
    var email = $('#user-email').val(), btn = $('#edit-email button[type=submit]');
    SL.buttonWorking(btn, true);
    if (SL.activeUser) {
        Parse.Cloud.run('modifyUser', {
            objectId: SL.activeUser.id,
            key: 'email',
            value: email
        }).then(function(result) {
            $('#preview-email .preview').html(email);
            SL.buttonWorking(btn, false);
            SL.showEditForm('email', false);
        }, function(error) {
            var msg = (error.message.hasOwnProperty('message')) ? error.message.message : error.message;

            $('#edit-email .messages').html('<div class="alert alert-danger">'+msg+'</div>')
            SL.buttonWorking(btn, false);

        });
    }
};

SL.setPass = function()
{
    var pass = $('#user-password').val(), btn = $('#edit-password button[type=submit]');
    SL.buttonWorking(btn, true);
    if (SL.activeUser) {
        Parse.Cloud.run('modifyUser', {
            objectId: SL.activeUser.id,
            key: 'password',
            value: pass
        }).then(function(result) {
            SL.buttonWorking(btn, false);
            SL.showEditForm('password', false);
        }, function(error) {
            var msg = (error.message.hasOwnProperty('message')) ? error.message.message : error.message;
            $('#edit-password .messages').html('<div class="alert alert-danger">'+msg+'</div>')
            SL.buttonWorking(btn, false);
        });
    }
};

SL.setAdjust = function(type, deviceId)
{
    var adjustValue = parseFloat($('#'+ type+ '-'+deviceId).val()), btn = $('#edit-'+ type+ '-'+deviceId+' button[type=submit]');
    SL.buttonWorking(btn, true);
    if (SL.activeUser && !isNaN(adjustValue)) {
        Parse.Cloud.run('modifyDevice', {
            objectId: deviceId,
            key: type+'Adjust',
            value: parseFloat(adjustValue)
        }).then(function(result) {
            $('#preview-'+ type+ '-'+deviceId +' .preview').html(adjustValue);
            SL.buttonWorking(btn, false);
            SL.showEditForm(type+'-'+deviceId, false);
        }, function(error) {
            var msg = (error.message.hasOwnProperty('message')) ? error.message.message : error.message;

            $('#edit-'+type+'-'+deviceId+ ' .messages').html('<div class="alert alert-danger">'+msg+'</div>')
            SL.buttonWorking(btn, false);
        });
    }
    else {
        $('#edit-'+type+'-'+deviceId+ ' .messages').html('<div class="alert alert-danger">Please enter a number</div>')
        SL.buttonWorking(btn, false);
    }
};

SL.loadMeasurements = function(deviceId, impeeId, start, limit)
{
    var Measurement = Parse.Object.extend("Measurement");
    var query = new Parse.Query(Measurement);
    query.equalTo("impeeId", impeeId);
    query.descending('createdAt');
    query.skip(start);
    query.limit(limit);
    query.find({
        success: function(results) {
            var items = _.map(results, function(item){ return item.toJSON(); });
            var tpl = SL.template('tpl-measurements');
            var hasMore = (items.length >= limit) ? true : false;
            var val = tpl({
                deviceId: deviceId,
                impeeId: impeeId,
                items: items,
                start: start,
                limit: limit,
                next: hasMore ? start+limit : 0
            });
            $('#measurements-'+deviceId +' .next').replaceWith(val);
        },
        error: function(error) {

        }
    });
};


SL.template = function (id) {
    var key = "#"+id, elem = $(key), tpl = null;
    if (!SL.templates.hasOwnProperty(key)) {
        tpl = SL.templates[key] = (elem.size()>0) ? _.template(elem.html()) : null;
    }
    else {
        tpl = SL.templates[key];
    }
    return tpl;
};

