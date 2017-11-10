<?php
require_once ('_includes/page_header.php');
?>



<div id="page-wrapper">
    <div class="container-fluid">
        <h1>User: <span class="user-value-name text-sl"></span></h1>

        <div id="user-info"></div>
        <div id="user-devices"></div>

    </div><!-- /.container-fluid -->
</div>
<!-- /#page-wrapper -->



</div>
<!-- /#wrapper -->


<script type="text/template" id="tpl-user-info">
    <div id="user-info">
        <h3>Info</h3>
        <table class="table table-striped">
            <tr><td width="150"><label>ID</label></td><td><%= objectId %></td></tr>
            <tr><td><label>Name</label></td><td><%= name %></td></tr>
            <tr>
                <td><label>Email</label></td>
                <td>
                    <div id="preview-email">
                        <span class="preview"><%= email %></span>
                        <a class="btn btn-link" onclick="return SL.showEditForm('email', true)"><i class="fa fa-edit fa-fw"></i> Edit</a>
                    </div>
                    <div id="edit-email" class="hidden">
                        <div class="messages"></div>
                        <div class="row">
                            <div class="col-xs-8">
                                <input type="text" id="user-email" value="<%= email %>" class="form-control">
                            </div>
                            <div class="col-xs-4">
                                <button onclick="SL.setEmail()" type="submit" class="btn btn-primary" data-text="Save" data-icon="fa-file-text-o" data-working-text="Saving..." data-working-icon="fa-refresh fa-spin"><i class="fa fa-fw fa-file-text-o"></i> <span class="text">Save</span></button>
                                <a onclick="return SL.showEditForm('email', false);" class="btn btn-link">Cancel</a>
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
                        <a class="btn btn-link" onclick="return SL.showEditForm('password', true)"><i class="fa fa-edit fa-fw"></i> Edit</a>
                    </div>
                    <div id="edit-password" class="hidden">
                        <div class="messages"></div>
                        <div class="row">
                            <div class="col-xs-8">
                                <input type="password" id="user-password" value="" class="form-control">
                            </div>
                            <div class="col-xs-4">
                                <button onclick="SL.setPass()" type="submit" class="btn btn-primary" data-text="Save" data-icon="fa-file-text-o" data-working-text="Saving..." data-working-icon="fa-refresh fa-spin"><i class="fa fa-fw fa-file-text-o"></i> <span class="text">Save</span></button>
                                <a onclick="return SL.showEditForm('password', false);" class="btn btn-link">Cancel</a>
                            </div>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td><label>Charcuterie</label></td>
                <td>
                    <input type="checkbox" data-onstyle="success" data-size="small" data-on="Enabled" data-off="Disabled" data-toggle="toggle" <% if (typeof(charcuterieEnabled) != 'undefined' && charcuterieEnabled) { %>checked<% } %> onchange="SL.enableCharcuterie(this)" value="1" data-status-icon="#working-charcuterie">
                    <i id="working-charcuterie" class="fa fa-fw" data-icon="fa-check text-success" data-working-icon="fa-refresh fa-spin"></i>
                </td>
            </tr>
            <tr>
                <td><label>Pro User</label></td>
                <td>
                    <input type="checkbox" data-onstyle="success" data-size="small" data-on="Enabled" data-off="Disabled" data-toggle="toggle" <% if (typeof(isProUser) != 'undefined' && isProUser) { %>checked<% } %> onchange="SL.enableProUser(this)" value="1" data-status-icon="#working-pro-user">
                    <i id="working-pro-user" class="fa fa-fw" data-icon="fa-check text-success" data-working-icon="fa-refresh fa-spin"></i>
                </td>
            </tr>
        </table>
    </div>
    <hr>
</script>

<script type="text/template" id="tpl-user-devices">
    <div id="user-devices">
        <h3>Devices</h3>

        <%
        if (items.length == 0) {
        print ('No connected devices');
        }
        else {
        %>


        <ul class="nav nav-tabs" role="tablist">
            <% for (var i in items) {
            device = items[i];
            %>
            <li role="presentation" class="<% if(i==0) { print('active'); } %>"><a href="#device-<%= device.objectId %>" aria-controls="settings" role="tab" data-toggle="tab"><%= device.nickname %></a></li>
            <% } %>
        </ul>


        <div class="tab-content">
            <% for (var i in items) {
            device = items[i];
            %>
            <div id="device-<%= device.objectId %>" role="tabpanel" class="tab-pane <% if(i==0) { print('active'); } %>">


                <table id="results" class="table table-striped">
                    <tr><td><label>Name</label><td><%= device.nickname %></td></tr>
                    <tr><td><label>ID</label><td><%= device.objectId %></td></tr>
                    <tr><td><label>Imp ID</label><td><%= device.impeeId %></td></tr>
                    <tr><td><label>Aging Type</label><td><%= device.agingType %></td></tr>
                    <tr><td><label>Created</label><td><% print(moment(device.createdAt).format('MMM Do YYYY, h:mm:ss A Z')); %></td></tr>
                    <tr><td><label>Humidity Setting</label><td><% if (typeof(device.settingHumidity) != 'undefined' && device.settingHumidity) { print(device.settingHumidity+'%'); } else { print('-'); } %></td></tr>
                    <tr><td><label>Last Measurement</label><td><% print(moment(device.lastMeasurementAt.iso).format('MMM Do YYYY, h:mm:ss A Z')); %></td></tr>
                    <tr>
                        <td><label>Humidity Adjustment</label></td>
                        <td>
                            <div id="preview-humidity-<%= device.objectId %>">
                                <span class="preview"><%= device.humidityAdjust %></span>
                                <a class="btn btn-link" onclick="return SL.showEditForm('humidity-<%= device.objectId %>', true)"><i class="fa fa-edit fa-fw"></i> Edit</a>
                            </div>
                            <div id="edit-humidity-<%= device.objectId %>" class="hidden">
                                <div class="messages"></div>
                                <div class="row">
                                    <div class="col-xs-8">
                                        <input type="text" id="humidity-<%= device.objectId %>" value="<%= device.humidityAdjust %>" class="form-control">
                                    </div>
                                    <div class="col-xs-4">
                                        <button onclick="SL.setAdjust('humidity', '<%= device.objectId %>')" type="submit" class="btn btn-primary" data-text="Save" data-icon="fa-file-text-o" data-working-text="Saving..." data-working-icon="fa-refresh fa-spin"><i class="fa fa-fw fa-file-text-o"></i> <span class="text">Save</span></button>
                                        <a onclick="return SL.showEditForm('humidity-<%= device.objectId %>', false);" class="btn btn-link">Cancel</a>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td><label>Temperature Adjustment</label></td>
                        <td>
                            <div id="preview-temperature-<%= device.objectId %>">
                                <span class="preview"><%= device.temperatureAdjust %></span>
                                <a class="btn btn-link" onclick="return SL.showEditForm('temperature-<%= device.objectId %>', true)"><i class="fa fa-edit fa-fw"></i> Edit</a>
                            </div>
                            <div id="edit-temperature-<%= device.objectId %>" class="hidden">
                                <div class="messages"></div>
                                <div class="row">
                                    <div class="col-xs-8">
                                        <input type="text" id="temperature-<%= device.objectId %>" value="<%= device.temperatureAdjust %>" class="form-control">
                                    </div>
                                    <div class="col-xs-4">
                                        <button onclick="SL.setAdjust('temperature', '<%= device.objectId %>')" type="submit" class="btn btn-primary" data-text="Save" data-icon="fa-file-text-o" data-working-text="Saving..." data-working-icon="fa-refresh fa-spin"><i class="fa fa-fw fa-file-text-o"></i> <span class="text">Save</span></button>
                                        <a onclick="return SL.showEditForm('temperature-<%= device.objectId %>', false);" class="btn btn-link">Cancel</a>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>

                    <tr><td><label>Actions</label></td><td align="right">
                            <a onclick="return SL.removeDevice('<%= device.user.objectId %>', '<%= device.objectId %>')" class="btn btn-xs btn-danger"><i class="fa fa-remove fa-fw"></i> Remove Device</a>
                        </td></tr>
                </table>


                <div id="measurements-<%= device.objectId %>">
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
                                <a class="btn btn-primary" onclick="SL.loadMeasurements('<%= device.objectId %>', '<%= device.impeeId %>', 0, 100)">Load Measurements</a>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <% } %>
        </div><!-- /.tab-content -->

        <% } %>
    </div>
</script>

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
            <a class="btn btn-default" onclick="SL.loadMeasurements('<%= deviceId %>', '<%= impeeId %>', <%= next %>, <%= limit %>)">Load More Measurements</a>
        </td>
    </tr>
    <% } %>
</script>



<?php
require_once ('_includes/body_end.php');
?>

<script>

    $(function() {
        var userId = SL.QueryString.get('id');

        SL.fetchUser(userId, function(user) {
            $('.user-value-name').html(user.get('name'));

            var tpl = SL.template('tpl-user-info'), val = '';
            $('#user-info').replaceWith(tpl(user.toJSON()));

            $('input[type=checkbox][data-toggle^=toggle]').bootstrapToggle();

            SL.fetchDevices(userId, function(items) {
                var tplD = SL.template('tpl-user-devices');
                $('#user-devices').replaceWith(tplD({'items':items}));
            });
        });
    });
</script>

<?php
require_once ('_includes/page_end.php');
?>
