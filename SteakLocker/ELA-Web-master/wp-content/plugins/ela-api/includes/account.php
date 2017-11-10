<?php

function ela_get_linked_users()
{
    $linked     = [];
    $wp_user_id = get_current_user_id();
    if ($wp_user_id > 0) {
        global $wpdb;
        $query  = sprintf("SELECT * FROM ela_account_bridge WHERE wp_user_id = %d", $wp_user_id);
        $linked = $wpdb->get_results($query, OBJECT);
    }
    return $linked;
}

function ela_get_linked_user($elaUser)
{
    /** @var Parse\ParseUser $elaUser */
    $linked     = [];
    $wp_user_id = get_current_user_id();
    if ($wp_user_id > 0) {
        global $wpdb;
        $query  = sprintf("SELECT * FROM ela_account_bridge WHERE wp_user_id = %d AND ela_user_id = '%s'",
            $wp_user_id, $elaUser->getObjectId());
        $linked = $wpdb->get_results($query, OBJECT);
    }
    return $linked;
}

function ela_unlink_user($elaUserId)
{
    /** @var Parse\ParseUser $elaUser */
    $linked     = [];
    $wp_user_id = get_current_user_id();
    if ($wp_user_id > 0 && $elaUserId) {
        global $wpdb;
        $wpdb->delete('ela_account_bridge', ['wp_user_id' => $wp_user_id, 'ela_user_id' => $elaUserId]);
    }
}




function ela_link_user($elaUser)
{
    global $wpdb;
    $linked = ela_get_linked_user($elaUser);

    /** @var Parse\ParseUser $elaUser */
    $data = [
        'wp_user_id' => get_current_user_id(),
        'ela_email'=> $elaUser->getEmail(),
        'ela_user_id' => $elaUser->getObjectId(),
        'ela_session_id' => $elaUser->getSessionToken()
    ];
    if ($linked) {
        $wpdb->update('ela_account_bridge', $data, ['id' => $linked->id]);
    }
    else {
        $wpdb->insert('ela_account_bridge', $data);
    }
}


function ela_get_devices()
{
    static $devices;

    $elaUsers = ela_get_linked_users();
    if ($devices === null && $elaUsers)
    {
        $userIds = array_map(function($u) { return $u->ela_user_id; }, $elaUsers);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_URL, 'https://steaklocker.herokuapp.com/devices?userId='.implode(',', $userIds));
        $result = curl_exec($ch);
        curl_close($ch);

        // Will dump a beauty json :3
        $response = json_decode($result);

        if ($response && $response->count > 0) {
            $devices = $response->items;
        }

        /*
        $response = \Parse\ParseCloud::run('getDeviceStatuses', ['userId' => $elaUser->getObjectId()], true);
        if ($response && $response['status'] == 'success' && $response['count'] > 0) {
            $devices = array_map(function($o){return (object)$o;}, $response['items']);
        }
        */
    }

    return $elaUsers ? $devices : [];
}


function ela_connect_form()
{
    return <<<HTML
<div class="container">

<form id="login-form" action="/api/account/login" method="POST" onsubmit="return ELA.login(this, 'Connecting...')">
    <div class="form">
        <h1>Connect your ELA app account</h1>
        <div class="form-group"><label for="login-email">Email</label>
            <input class="form-control" name="email" type="email" />
        </div>
        <div class="form-group"><label for="login-pass">Password</label>
            <input class="form-control" name="pass" type="password" />
        </div>
        <div class="form-group">
            <button class="avia-button avia-color-black avia-size-x-large avia-position-center" type="submit">Connect</button>
        </div>
    </div>
</form>
</div>
HTML;
}
add_shortcode('ela_connect_form', 'ela_connect_form');


function ela_dashboard_device_info($device)
{
    $deviceId    = $device->_id;
    $impeeId     = $device->impeeId;
    $nickname    = $device->nickname;
    $agingType   = $device->agingType;
    $deviceType  = $device->type;
    $statusTemp  = $device->statusTemp;
    $statusHumid = $device->statusHumid;
    $count     = $device->count;
    $lastMeas  = $device->lastMeasurementAt;
    $lastTempC = $device->lastTemperatureC;
    $lastTempF = round($device->lastTemperatureF);
    $lastHumid = round($device->lastHumidity);

    $userId    = str_replace('_User$', '', $device->_p_user);

    $now  = new DateTime();
    $diff = $now->diff(($lastMeas instanceof DateTime) ? $lastMeas : new DateTime($lastMeas));

    $lastSync = '';
    $parts    = [];

    if ($diff->h) {
        $h  = ($diff->days) ? 24 * $diff->days : 0;
        $h += $diff->h;
        $parts[] = sprintf("%d hours", $h);
    }
    if ($diff->i) {
        $parts[] = $diff->format('%i minutes');
    }
    $lastSync = implode(', ', $parts);

    $output = <<<DEVICE
    <div id="$deviceId"><div class="device {$deviceType}">
        <div class="row">
            <div class="col-xs-12 col-lg-6">
                <div class="row">
                    <div class="col-xs-12 col-md-4 col-lg-3">
                        <div class="ela-device-images">
                        <img src="/assets/product-{$deviceType}.png" class="device-image" /><img src="/assets/icon-{$deviceType}.png" class="device-icon" />
                        </div>
                    </div>
                    <div class="col-xs-12 col-md-8 col-lg-9">
                        <h1>{$nickname}</h1>
                        <div class="last-sync">
                        [av_font_icon icon='ue891' font='entypo-fontello' style='' size='25px' position='left' color=''][/av_font_icon]<div>Last sync {$lastSync} ago</div>
                        </div>
                        <div class="unlink"><a href="/api/account/unlink?u={$userId}">Unlink</a></div>
                    </div>
                </div>
            </div>
            <div class="col-xs-12 col-lg-6">
                <div class="row">
                    <div class="col-xs-12 col-md-4">
                        <div class="data-point">
                            <div class="value"><span>{$lastTempF}</span><div class="sup">f</div><div class="status-dot {$statusTemp}"></div></div>
                            <div class="suffix">Temperature</div>
                        </div>
                    </div>
                    <div class="col-xs-12 col-md-4">
                        <div class="data-point">
                            <div class="value"><span>{$lastHumid}</span><div class="sup">%</div><div class="status-dot {$statusHumid}"></div></div>
                            <div class="suffix">Humidity</div>
                        </div>
                    </div>
                    <div class="col-xs-12 col-md-4">
                        <div class="data-point">
                            <div class="value"><span>{$count}</span></div>
                            <div class="suffix">Items</div>
                        </div>
                    </div>
                </div>
            </div>
        </div><a class="expand" onclick="return ELA.loadMeasurements('{$deviceId}', '{$impeeId}', '{$deviceType}');">[av_font_icon icon='ue869' font='entypo-fontello' size='30px'][/av_font_icon]</a><a class="shrink" onclick="return ELA.closeMeasurements('{$deviceId}', '{$impeeId}', '{$deviceType}');">[av_font_icon icon='ue86a' font='entypo-fontello' size='30px'][/av_font_icon]</a>
        <div id="measurements-{$deviceId}" class="measurements">
            <table class="table table-striped">
                <thead>
                <tr>
                    <th>Date</th>
                    <th style="text-align:right">Temp &deg;F</th>
                    <th style="text-align:right">Temp &deg;C</th>
                    <th style="text-align:right">Humidity %</th>
                </tr>
                </thead>
                <tbody>
                <tr class="next">
                    <td colspan="4" align="center">
                        <a class="btn btn-primary" onclick="ELA.SL.loadMeasurements('{$deviceId}', '{$impeeId}', 0, 100)">Loading measurements...</a>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>        
    </div></div>

DEVICE;


    return $output;
}


function ela_dashboard_connect_device($deviceType, $deviceTypeName)
{
    $output = <<<DEVICE
    <div id="connect-$deviceType"><div class="device {$deviceType}">
        <div class="row">
            <div class="col-xs-12 col-lg-6">
                <div class="row">
                    <div class="col-xs-12 col-md-4 col-lg-3">
                        <div class="ela-device-images">
                        <img src="/assets/product-{$deviceType}.png" class="device-image" /><img src="/assets/icon-{$deviceType}.png" class="device-icon" />
                        </div>
                    </div>
                    <div class="col-xs-12 col-md-8 col-lg-9">
                        <h1>Connect Your {$deviceTypeName}</h1>
                    </div>
                </div>
            </div>
            <div class="col-xs-12 col-lg-6" style="text-align: center">
                <a href="/ela-connect" class="avia-button avia-color-black avia-size-x-large avia-position-center">Connect</a>
            </div>
        </div>
    </div></div>

DEVICE;


    return $output;
}



function ela_dashboard_footer()
{
    if (is_page('dashboard') || is_page('account') || is_page('ela-connect')) {
        $devices = ela_get_devices();
        $output  = '';
        foreach ($devices as $device) {
            $deviceId = $device->_id;
            $output .= <<<HTML
    <div id="modal-{$deviceId}" class="modal" tabindex="-1" role="dialog">
      <div class="modal-dialog modal-xl"" role="document">
        <div class="modal-content">
          <div class="modal-body">
            
            
          </div>
        </div>
      </div>
    </div>
HTML;
        }


        $output .= <<<SL_JS
<script src="https://npmcdn.com/parse/dist/parse.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.17.1/moment.min.js"></script>
SL_JS;

        $output .= <<<SL_JS

<script type="text/template" id="tpl-measurements">
    <% for (var i in items) {
    measurement = items[i];
    tempC = measurement.hasOwnProperty('temperature') ? measurement.temperature : '-';
    tempF = (tempC=='-') ? '-' : (tempC * (9/5)) + 32;
    tempC = Math.round(tempC*10)/10;
    tempF = Math.round(tempF*10)/10;
    %>
    <tr>
        <td><% print(moment(measurement.createdAt).format('MMM Do YYYY, h:mm:ss A Z')); %></td>
        <td align="right"><%= tempF %>&deg;</td>
        <td align="right"><%= tempC %>&deg;</td>
        <td align="right"><%= Math.round(10 * measurement.humidity) / 10 %>%</td>
    </tr>
    <% } %>
    <% if (next > 0 && next < 1000) { %>
    <tr class="next">
        <td colspan="4" align="center">
            <a class="button" onclick="ELA.SL.loadMeasurements('<%= deviceId %>', '<%= impeeId %>', <%= next %>, <%= limit %>)">Load More Measurements</a>
        </td>
    </tr>
    <% } %>
</script>
SL_JS;
        echo $output;
    }
}
add_action('wp_footer', 'ela_dashboard_footer');

function ela_dashboard_devices()
{
    $output = '';
    $linked = ela_get_linked_users();
    if ($linked) {
        $devices = ela_get_devices();
        foreach ($devices as $device) {
            $output .= ela_dashboard_device_info($device);
        }
        $output .= '<a href="/ela-connect">Connect another ELA device</a>';
    }
    else {
        $output .= ela_dashboard_connect_device('steaklocker', 'Steak Locker');
        $output .= ela_dashboard_connect_device('winelocker', 'Wine Locker');
        $output .= ela_dashboard_connect_device('beerlocker', 'Beer Locker');
    }


    return $output;

}





/*
function ela_get_auth_user()
{
    $linked = ela_get_linked_user();
    $user   = null;
    if ($linked) {
        $user = \Parse\ParseUser::getCurrentUser();
        if (!$user) {
            $user = Parse\ParseUser::become($linked->ela_session_id);
        }
        elseif ($linked->ela_user_id != $user->getObjectId()) {
            $user = Parse\ParseUser::become($linked->ela_session_id);
        }
    }
    return $user;
}


function ela_account_form()
{

    $user = ela_get_auth_user();
    if (!$user) {
        return '';
    }
    $id = $user->getObjectId();
    $name  = $user->get('name');
    $email = $user->getEmail();

    $output = <<<SL_JS
<div id="user-info">
    <h3>Account</h3>
    <table class="table table-striped">
        <tbody>
        <tr>
            <td><label>Name</label></td>
            <td>
                <div id="preview-name">
                    <span class="preview">{$name}</span>
                    <a class="btn btn-link" onclick="return ELA.showEditForm('name', true)"><i class="fa fa-edit fa-fw"></i> Edit</a>
                </div>
                <div id="edit-name" class="hidden">
                    <div class="messages"></div>
                    <div class="row">
                        <div class="col-xs-8">
                            <input type="text" id="user-name" value="{$name}" class="form-control">
                        </div>
                        <div class="col-xs-4">
                            <button onclick="ELA.setName()" type="submit" class="btn btn-primary" data-text="Save" data-icon="fa-file-text-o" data-working-text="Saving..." data-working-icon="fa-refresh fa-spin"><i class="fa fa-fw fa-file-text-o"></i> <span class="text">Save</span></button>
                            <a onclick="return ELA.showEditForm('name', false);" class="btn btn-link">Cancel</a>
                        </div>
                    </div>
                </div>
            </td>
        </tr>
        <tr>
            <td><label>Email</label></td>
            <td>
                <div id="preview-email">
                    <span class="preview">{$email}</span>
                    <a class="btn btn-link" onclick="return ELA.showEditForm('email', true)"><i class="fa fa-edit fa-fw"></i> Edit</a>
                </div>
                <div id="edit-email" class="hidden">
                    <div class="messages"></div>
                    <div class="row">
                        <div class="col-xs-8">
                            <input type="text" id="user-email" value="{$email}" class="form-control">
                        </div>
                        <div class="col-xs-4">
                            <button onclick="ELA.setEmail()" type="submit" class="btn btn-primary" data-text="Save" data-icon="fa-file-text-o" data-working-text="Saving..." data-working-icon="fa-refresh fa-spin"><i class="fa fa-fw fa-file-text-o"></i> <span class="text">Save</span></button>
                            <a onclick="return ELA.showEditForm('email', false);" class="btn btn-link">Cancel</a>
                        </div>
                    </div>
                </div>
            </td>
        </tr>
        <tr>
            <td><label>Password</label></td>
            <td>
                <div id="preview-password">
                    <span class="preview">**************</span>
                    <a class="btn btn-link" onclick="return ELA.showEditForm('password', true)"><i class="fa fa-edit fa-fw"></i> Edit</a>
                </div>
                <div id="edit-password" class="hidden">
                    <div class="messages"></div>
                    <div class="row">
                        <div class="col-xs-8">
                            <input type="password" id="user-password" value="" class="form-control">
                        </div>
                        <div class="col-xs-4">
                            <button onclick="ELA.setPass()" type="submit" class="btn btn-primary" data-text="Save" data-icon="fa-file-text-o" data-working-text="Saving..." data-working-icon="fa-refresh fa-spin"><i class="fa fa-fw fa-file-text-o"></i> <span class="text">Save</span></button>
                            <a onclick="return ELA.showEditForm('password', false);" class="btn btn-link">Cancel</a>
                        </div>
                    </div>
                </div>
            </td>
        </tr>

        </tbody></table>
        <div style="padding: 30px 0"><a href="/api/account/logout">Log Out</a></div>
</div>
SL_JS;
    return $output;


}
add_shortcode('ela_account_form', 'ela_account_form');
*/