window.ELA = {};
ELA.SL = ELA.SL || {};
ELA.WL = ELA.WL || {};
ELA.BL = ELA.BL || {};
(function($) {

ELA.QueryString = ELA.QueryString || {};
ELA.QueryString._data = false;
ELA.QueryString.parse = function (queryString) {
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

ELA.QueryString.get = function(name) {
    if (!ELA.QueryString._data) {
        ELA.QueryString._data = ELA.QueryString.parse();
    }
    if (ELA.QueryString._data) {
        if (typeof(ELA.QueryString._data[name]) != 'undefined') {
            return ELA.QueryString._data[name];
        }
    }
    return false;
};




ELA.templates = {};
ELA.buttonWorking = function(btn, on) {
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
ELA.iconWorking = function(icon, on) {
    var I = $(icon), icon=I.data('icon'), iconW=I.data('workingIcon');

    if (on) {
        I.removeClass(icon).addClass(iconW);
    }
    else {
        I.removeClass(iconW).addClass(icon);
    }
};

ELA.showEditForm = function (key, editing)
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


ELA.post = function (url, data, successCallback, errorCallback)
{
    var options = { dataType: 'jsonp' };
    var settings = $.extend({
        type: 'POST',
        url: url,
        data: data || {},
        dataType: 'json'
    }, options || {});

    $.ajaxSetup({
        type: 'POST',
        success: function (response) {
            if (successCallback) {
                successCallback(response);
            }
        },
        error: function (xhr, status, err) {
            if (errorCallback) {
                errorCallback(xhr, status, err);
            }
        }
    });
    $.ajax(settings);

    return false;
};

ELA.fieldError = function (fieldName, message) {
    $('#edit-'+fieldName+' .messages').html('<div class="alert alert-danger">'+message+'</div>');
};

ELA.setFieldPreview = function(fieldName, value)
{
    var preview = (fieldName === 'password') ? '*************' : value;
    $('#preview-'+fieldName+' .preview').html(preview);
};

ELA.setField = function(fieldName) {
    var field = $('#user-'+fieldName).val(), btn = $('#edit-'+fieldName+' button[type=submit]');
    ELA.buttonWorking(btn, true);

    var data = {};
    data[fieldName] = field;

    return ELA.post('/api/account/update', data, function(response) {
        var status = response.hasOwnProperty('status') ? response.status : 'error';
        var error  = response.hasOwnProperty('error') ? response.error : '';

        if (status == 'ok') {
            ELA.buttonWorking(btn, false);
            ELA.setFieldPreview(fieldName, field);
            ELA.showEditForm(fieldName, false);
        }
        else {
            ELA.fieldError(fieldName, error ? error : 'An error occurred');
        }
    }, function(xhr, status, error) {
        var msg = (error.message.hasOwnProperty('message')) ? error.message.message : error.message;
        ELA.fieldError(fieldName, msg);

        ELA.buttonWorking(btn, false);
    });
};

ELA.setName = function()
{
    return ELA.setField('name');
};
ELA.setEmail = function()
{
    return ELA.setField('email');
};

ELA.setPass = function()
{
    return ELA.setField('password');
};

ELA.template = function (id) {
    var key = "#"+id, elem = $(key), tpl = null;
    if (!ELA.templates.hasOwnProperty(key)) {
        tpl = ELA.templates[key] = (elem.size()>0) ? _.template(elem.html()) : null;
    }
    else {
        tpl = ELA.templates[key];
    }
    return tpl;
};


})(jQuery);


jQuery(function($) {
Parse.initialize('MEhfCXacMGU4wU9R7GNImyxP8766VJwCpnvE4ctI');
Parse.serverURL = 'https://steaklocker.herokuapp.com/parse';


ELA.loadMeasurements = function(deviceId, impeeId, deviceType)
{
    var content = $('#'+deviceId).html(), M = $('#modal-'+deviceId);

    M.find('.modal-body').html(content);
    ELA.SL.loadMeasurements(deviceId, impeeId, 0, 100);
    M.modal();
};
ELA.closeMeasurements = function(deviceId, impeeId, deviceType)
{
    var content = $('#'+deviceId).html(), M = $('#modal-'+deviceId);
    M.modal('hide');
};

ELA.SL.loadMeasurements = function(deviceId, impeeId, start, limit)
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
            var tpl = ELA.template('tpl-measurements');

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
            console.log(error);
        }
    });
};

});