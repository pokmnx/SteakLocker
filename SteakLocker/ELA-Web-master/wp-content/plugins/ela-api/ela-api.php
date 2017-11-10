<?php
/*
Plugin Name: ELA API via Parse Server
Description: Bridge between SteakLocker and wordpress
Version: 1.0
Author: Jared Ashlock
*/

define( 'WP_PARSE_API_PATH',             plugin_dir_path(__FILE__));

require_once WP_PARSE_API_PATH . 'libs/parse-php-sdk/autoload.php';
require_once WP_PARSE_API_PATH . 'includes/class-wp-parse-api-helpers.php';
require_once WP_PARSE_API_PATH . 'includes/class-wp-parse-api-admin-settings.php';
require_once WP_PARSE_API_PATH . 'includes/account.php';

add_action('wp_loaded', [WpParseApi::get_instance(), 'register']);

function ela_stylesheets() {
    //wp_register_script( 'ela', 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js');
    wp_register_script( 'ela', '/assets/ela.js');
    wp_enqueue_script('ela');

    wp_register_script( 'ela-admin-bootstrap', '/assets/bootstrap/js/bootstrap.min.js');
    wp_register_style('ela-admin-bootstrap', '/assets/bootstrap/css/bootstrap.min.css');
    wp_register_script( 'ela-admin', '/assets/ela-admin.js');
    wp_register_style('ela-admin', '/assets/ela-admin.css');

    if (is_page('dashboard') || is_page('account')) {
        wp_enqueue_script('ela-admin-bootstrap');
        wp_enqueue_script('ela-admin');
        wp_enqueue_style('ela-admin-bootstrap');
        wp_enqueue_style('ela-admin');
    }
}
add_action('wp_enqueue_scripts', 'ela_stylesheets', 30);



function ela_product_url_function($atts){
    global $wpdb;

    if ( empty( $atts ) ) {
        return '';
    }

    if ( isset( $atts['id'] ) ) {
        $product_data = get_post( $atts['id'] );
    } elseif ( isset( $atts['sku'] ) ) {
        $product_id   = wc_get_product_id_by_sku( $atts['sku'] );
        $product_data = get_post( $product_id );
    } else {
        return '';
    }

    if ( 'product' !== $product_data->post_type ) {
        return '';
    }

    $_product = wc_get_product( $product_data );

    return esc_url( get_post_permalink($_product->id) );
}
add_shortcode( 'product_url', 'ela_product_url_function' );





function product_box($key, $attrs = [], $content = null, $tag = '')
{
    $url = !empty($attrs['url']) ? $attrs['url'] : sprintf('/%s', $key);
    $subtitle = !empty($attrs['subtitle']) ? $attrs['subtitle'] : '&nbsp;';
    $html     = <<<HTML
<a href="{$url}" class="box product-box noHover">
    <div class="product-images"><img src="/assets/product-{$key}.png" class="product-image" /><img src="/assets/product-{$key}-over.png" class="product-image-hover" /></div>
    <div><img src="/assets/logo-{$key}.png" class="product-logo" /></div>
    <h4 class="subtitle">{$subtitle}</h4>
</a>

HTML;
    return $html;
}

function product_box_steaklocker($attrs = [], $content = null, $tag = '')
{
    if (empty($attrs['url'])) {
        $attrs['url'] = '/steaklocker';
    }
    $attrs['subtitle'] = 'Steak House-quality dry age steaks and charcuterie in your home.';
    return product_box('steaklocker', $attrs, $content, $tag);
}
add_shortcode('product_box_steaklocker', 'product_box_steaklocker');

function product_box_steaklocker_pro($attrs = [], $content = null, $tag = '')
{
    if (empty($attrs['url'])) {
        $attrs['url'] = '/steaklocker-pro';
    }
    $attrs['subtitle'] = 'Elevate your dry-aging program quickly and effectively with our professional series';
    return product_box('steaklocker-pro', $attrs, $content, $tag);
}
add_shortcode('product_box_steaklocker_pro', 'product_box_steaklocker_pro');

function product_box_winelocker($attrs = [], $content = null, $tag = '')
{
    if (empty($attrs['url'])) {
        $attrs['url'] = '/winelocker';
    }
    $attrs['subtitle'] = 'An elevated environment for your wine collections at home.';
    return product_box('winelocker', $attrs, $content, $tag);
}
add_shortcode('product_box_winelocker', 'product_box_winelocker');

function product_box_beerlocker($attrs = [], $content = null, $tag = '')
{
    if (empty($attrs['url'])) {
        $attrs['url'] = '/beerlocker';
    }
    $attrs['subtitle'] = 'An elevated environment for your craft beer collections.';
    return product_box('beerlocker', $attrs, $content, $tag);
}
add_shortcode('product_box_beerlocker', 'product_box_beerlocker');




function product_help_header($key, $attrs = [], $content = null, $tag = '')
{
    $html = <<<HTML
<div class="help-header clearfix">
<div class="container">
<img src="/assets/logo-{$key}-black.png" class="product-logo" />
<img src="/assets/product-{$key}.png" class="product-image" />
</div>
</div>
HTML;
    return $html;
}

function product_help_header_steaklocker($attrs = [], $content = null, $tag = '')
{
    if (empty($attrs['url'])) {
        $attrs['url'] = '/steaklocker';
    }
    return product_help_header('steaklocker', $attrs, $content, $tag);
}
add_shortcode('product_help_header_steaklocker', 'product_help_header_steaklocker');

function product_help_header_steaklocker_pro($attrs = [], $content = null, $tag = '')
{
    if (empty($attrs['url'])) {
        $attrs['url'] = '/steaklocker-pro';
    }
    return product_help_header('steaklocker', $attrs, $content, $tag);
}
add_shortcode('product_help_header_steaklocker_pro', 'product_help_header_steaklocker_pro');

function product_help_header_winelocker($attrs = [], $content = null, $tag = '')
{
    if (empty($attrs['url'])) {
        $attrs['url'] = '/winelocker';
    }
    return product_help_header('winelocker', $attrs, $content, $tag);
}
add_shortcode('product_help_header_winelocker', 'product_help_header_winelocker');

function product_help_header_beerlocker($attrs = [], $content = null, $tag = '')
{
    if (empty($attrs['url'])) {
        $attrs['url'] = '/beerlocker';
    }
    return product_help_header('beerlocker', $attrs, $content, $tag);
}
add_shortcode('product_help_header_beerlocker', 'product_help_header_beerlocker');



function ela_page_header($attrs = [], $content = null, $tag = '')
{
    $title_prefix  = isset($attrs['title_prefix']) ? $attrs['title_prefix'] : '';
    $title         = isset($attrs['title']) ? $attrs['title'] : '';
    $title_suffix  = isset($attrs['title_suffix']) ? $attrs['title_suffix'] : '';
    $button        = isset($attrs['button']) ? $attrs['button'] : 'Learn More';
    $button_url    = isset($attrs['button_url']) ? $attrs['button_url'] : '';
    $scroll_down   = isset($attrs['scroll_down']) ? $attrs['scroll_down'] : '';

    $output = sprintf('<div class="ela-section text-center" style="color:%s;">', $color);
    if ($title_prefix) {
        $output .= '<h3>'. $title_prefix .'</h3>';
    }
    if ($title) {
        $output .= '<h1>'. $title .'</h1>';
    }
    if ($title_suffix) {
        $output .= '<h3>'. $title_suffix .'</h3>';
    }
    if ($button && $button_url) {
        $output .= sprintf('<div style="margin-top:50px;margin-bottom:50px"><a href="%s" class="button">%s</a></div>', $button_url, $button);
    }

    if ($scroll_down) {
        $output .= '<h4><a href="#more-info">'. $scroll_down .'</a></h4>';
    }

    $output .= '</div><div id="more-info"></div>';

    return $output;
}
add_shortcode('ela_page_header', 'ela_page_header');



function ela_help_search_form() {
    $form = <<<EOH
    <div style="background: #fff; border-radius: 4px; padding:20px; margin: 20px 0">
<form role="search" method="get" id="search-help" class="search-form" action="/category/help">
<label class="" for="s">Search ELA Help</label>
<input type="text" value="" name="s" id="s" />
<input type="submit" value="Search" />
</form>
</div>
EOH;
    $form = <<<EOH
    <form action="/" class="ela-simple-form" method="get" data-name="Search ELA Help">
        <div class="form-fields">
            <p>
                <label for="search-help">Search by keyword or phrase: </label>
                <input type="text" name="s" id="search-help" placeholder="Search by keyword or phrase" />
            </p>
            <p>
	            <input type="submit" value="Search">
            </p>
        </div>
    </form>
EOH;

    return $form;
}

add_shortcode('helpsearch', 'ela_help_search_form');


class WpParseApi
{
    /**
     * Plugin instance.
     *
     * @see get_instance()
     * @type object
     */
    protected static $instance = NULL;
    
    protected $action = 'wpparseapi_79898';
    protected $option_name = 'wpparseapi_79898';
    protected $page_id     = NULL;

    function __construct()
    {
        // Add a custom controller
        add_filter('json_api_controllers', [ __CLASS__, 'ela_add_json_controllers' ]);

        // Register the source file for JSON_API_Contact_Controller
        add_filter('json_api_account_controller_path', [__CLASS__, 'ela_account_controller_path']);
    }

    public static function ela_add_json_controllers($controllers)
    {
        $controllers[] = 'account';
        return $controllers;
    }

    public static function ela_account_controller_path($default_path) {

        return __DIR__ . '/json-controllers/account.php';
    }

    /**
     * Access this plugin’s working instance
     *
     * @wp-hook wp_loaded
     * @return  object of this class
     */
    public static function get_instance()
    {
        WpParseApiHelpers::log('WpParseApi::get_instance()');
        NULL === self::$instance and self::$instance = new self;
        return self::$instance;
    }
    
    /**
     * Add the hook to create/update the post on parse.com
     *
     */
    public function register()
    {
        //WpParseApiHelpers::log('WpParseApi::register()');
        //add_action('save_post', array($this, 'save_post'));
        if ( !session_id() ) {
            session_start();
        }
        $appId     = get_option('app_id');
        $restKey   = get_option('app_restkey');
        $masterKey = get_option('app_masterkey');
        \Parse\ParseClient::initialize($appId, $restKey, $masterKey, $enableCurlExceptions = true, $account_key = null);
        \Parse\ParseClient::setServerURL('https://steaklocker.herokuapp.com','parse');
    }
    
    /**
     * Create/Update the post on parse.com
     *
     */
    public function save_post($post_id)
    {
        WpParseApiHelpers::log("WpParseApi::save_post($post_id) | START");
        
        // Verify post is a revision
        if (wp_is_post_revision($post_id)) return;
        // Check if the parse api app id is defined
        if (!defined('WP_PARSE_API_APP_ID') || WP_PARSE_API_APP_ID == null) return;
        WpParseApiHelpers::log("WpParseApi::save_post($post_id) | WP_PARSE_API_APP_ID passed");
        // Verify post is an autosave
        if (defined('DOING_AUTOSAVE') && DOING_AUTOSAVE) return;
        WpParseApiHelpers::log("WpParseApi::save_post($post_id) | DOING_AUTOSAVE passed");
        // Verify post nonce
        // if (!wp_verify_nonce( $_POST[ $this->option_name . '_nonce' ], $this->action)) return;
        // WpParseApiHelpers::log("WpParseApi::save_post($post_id) | nonce passed");
        // Verify post status
        if (get_post_status($post_id) != 'publish') return;
        WpParseApiHelpers::log("WpParseApi::save_post($post_id) | status passed");
    
        $post = WpParseApiHelpers::postToObject($post_id);
    
        // Creates a new post on parse.com
        if (!get_post_meta($post_id, 'wp_parse_api_code_run', true)) {
            update_post_meta($post_id, 'wp_parse_api_code_run', true);
            
            $categories = array();
            
            foreach ($post->data['categories'] as $row) {
                $row = trim(preg_replace('/[^a-zA-Z]/', '', $row));
                if ($row != '') $categories[] = $row;
            }
            
            // Check if there is no categories or push notifications are disabled
            if (is_array($categories) && count($categories) > 0 && get_option('app_push_notifications') != 'Off') {
                try {
                    $push = new parsePush();
                    $push->alert = $post->data['title'];
                    $push->channels = $categories;
                    $push->badge = "increment";
                    $push->sound = "example.caf";
                    $push->post_id = $post->data[wpId];
                    $push->url = $post->data['guid'];
                    $push->category = "ACTIONABLE";
                    $push->send();                } 
                    catch (Exception $e) {
                    // do nothing, this was added because 
                    // parse lib throws an exception if the account
                    // has not been configured
                    // special thanks to raymondmuller for find the issue
                }
            }
            
            $post->save();
        // Update an existin post on parse.com
        } else {
            $q = new parseQuery(WP_PARSE_API_OBJECT_NAME);
            $q->where('wpId', (int)$post_id);
            $r = $q->find();
        
            if (is_array($r->results)) $r = array_shift($r->results);
            if ($r != null) $post->update($r->objectId);
        }
        
        WpParseApiHelpers::log("WpParseApi::save_post($post_id) | END");
    }
}
