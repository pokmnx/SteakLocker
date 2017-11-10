<?php
if (!defined('WP_PARSE_API_PATH')) die('.______.');

if (!current_user_can('manage_options')) {
    wp_die(__('You do not have sufficient permissions to access this page.'));
}
?>
<div class="wrap">
    <div id="icon-options-general" class="icon32"><br></div>
    <h2>Parse Api</h2>

    <p>Register your app on <a href="http://parse.com" target="_blank">parse.com</a> then complete this form with the information about your app.</p>

    <form action="options.php" method="post">
        <?php settings_fields('wp-parse-api-settings-group'); ?>
        <?php //do_settings('wp-parse-api-settings-group'); ?>
        
        <h3>Settings</h3>
        
        <table class="form-table">
			<tr valign="top">
				<th  scope="row">API URL</th>
				<td><input type="text" name="parse_url" value="<?php echo get_option('parse_url'); ?>"></td>
			</tr>
            <tr valign="top">
                <th  scope="row">App ID</th>
                <td><input type="text" name="app_id" value="<?php echo get_option('app_id'); ?>"></td>
            </tr>
            <tr valign="top">
                <th  scope="row">App Masterkey</th>
                <td><input type="text" name="app_masterkey" value="<?php echo get_option('app_masterkey'); ?>"></td>
            </tr>
            <tr valign="top">
                <th  scope="row">App Rest Key</th>
                <td><input type="text" name="app_restkey" value="<?php echo get_option('app_restkey'); ?>"></td>
            </tr>
            <tr valign="top">
                <th  scope="row">Push notifications</th>
                <td>
                    <select name="app_push_notifications">
                        <option>On</option>
                        <option<?php
                            echo get_option('app_push_notifications') == 'Off' ? ' selected="selected"':''
                        ?>>Off</option>
                    </select>
                </td>
            </tr>
            <tr valign="top">
                <th  scope="row">Select date language</th>
                <td>
                    <select name="lang">
                        <option value="en">English</option>
                        <option value="es" <?php
                            echo get_option('lang') == 'es' ? ' selected="selected"':''
                        ?>>Español</option>
                    </select>
                </td>
            </tr>
        </table>

        <?php submit_button(); ?>
    </form>
</div>