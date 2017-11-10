<?php

/*
 * wpml multi site config file
 * needs to be loaded before the framework
 */

require_once( dirname(__FILE__) .'/../enfold/config-wpml/config.php' );

foreach (glob(dirname(__FILE__)."/override/*.php") as $filename) {
    require_once($filename) ;
}




add_action( 'init', 'create_help_post_type' );
function create_help_post_type() {
    global $avia_config;
    $labels = [
        'name' => _x('Help Items', 'post type general name','avia_framework'),
        'singular_name' => _x('Help Entry', 'post type singular name','avia_framework'),
        'add_new' => _x('Add New', 'help','avia_framework'),
        'add_new_item' => __('Add New Help Entry','avia_framework'),
        'edit_item' => __('Edit Help Entry','avia_framework'),
        'new_item' => __('New Help Entry','avia_framework'),
        'view_item' => __('View Help Entry','avia_framework'),
        'search_items' => __('Search Help Entries','avia_framework'),
        'not_found' =>  __('No Help Entries found','avia_framework'),
        'not_found_in_trash' => __('No Help Entries found in Trash','avia_framework'),
        'parent_item_colon' => ''
    ];

    $permalinks = get_option('avia_permalink_settings');
    if(!$permalinks) $permalinks = array();

    $permalinks['help_permalink_base'] = empty($permalinks['help_permalink_base']) ? __('help', 'avia_framework') : $permalinks['help_permalink_base'];
    $permalinks['help_entries_taxonomy_base'] = empty($permalinks['help_entries_taxonomy_base']) ? __('help_entries', 'avia_framework') : $permalinks['help_entries_taxonomy_base'];

    $args = [
        'menu_position' => 4,
        'labels' => $labels,
        'public' => true,
        'show_ui' => true,
        'capability_type' => 'post',
        'hierarchical' => false,
        'rewrite' => array('slug'=>_x($permalinks['help_permalink_base'],'URL slug','avia_framework'), 'with_front'=>true),
        'query_var' => true,
        'show_in_nav_menus'=> true,
        'taxonomies' => array('post_tag', 'category'),
        'supports' => array('title','thumbnail','excerpt','editor','comments'),
        'menu_icon' => 'dashicons-images-alt2'
    ];

    $args = apply_filters('avf_help_cpt_args', $args);
    $avia_config['custom_post']['help']['args'] = $args;

    register_post_type( 'help' , $args );
}

// Show posts of 'post', 'page', 'acme_product' and 'movie' post types on home page
function search_filter( $query ) {
    if ( !is_admin() && $query->is_main_query() ) {
        if ( $query->is_search ) {
            $query->set( 'post_type', array( 'help' ) );
        }
    }
}

add_action( 'pre_get_posts','search_filter' );



add_action( 'init', 'create_snippet_post_type' );
function create_snippet_post_type() {
    global $avia_config;
    $labels = [
        'name' => _x('Snippet Items', 'post type general name','avia_framework'),
        'singular_name' => _x('Snippet Entry', 'post type singular name','avia_framework'),
        'add_new' => _x('Add New', 'help','avia_framework'),
        'add_new_item' => __('Add New Snippet Entry','avia_framework'),
        'edit_item' => __('Edit Snippet Entry','avia_framework'),
        'new_item' => __('New Snippet Entry','avia_framework'),
        'view_item' => __('View Snippet Entry','avia_framework'),
        'search_items' => __('Search Snippet Entries','avia_framework'),
        'not_found' =>  __('No Snippet Entries found','avia_framework'),
        'not_found_in_trash' => __('No Snippet Entries found in Trash','avia_framework'),
        'parent_item_colon' => ''
    ];

    $args = [
        'menu_position' => 4,
        'labels' => $labels,
        'public' => true,
        'show_ui' => true,
        'capability_type' => 'post',
        'hierarchical' => false,
        'query_var' => true,
        'supports' => array('title','thumbnail','editor'),
        'menu_icon' => 'dashicons-images-alt2'
    ];

    $args = apply_filters('avf_snippet_cpt_args', $args);
    $avia_config['custom_post']['snippet']['args'] = $args;

    register_post_type( 'snippet' , $args );
}


add_filter('avf_builder_boxes','custom_post_types_options');
function custom_post_types_options($boxes)
{

    $boxes = array(
        array( 'title' =>__('Avia Layout Builder','avia_framework' ), 'id'=>'avia_builder', 'page'=>array('page','post','help','snippet'), 'context'=>'normal', 'priority'=>'high', 'expandable'=>true ),
        array( 'title' =>__('Layout','avia_framework' ), 'id'=>'layout', 'page'=>array('page','post','help','snippet'), 'context'=>'side', 'priority'=>'low'),
        array( 'title' =>__('Breadcrumb Hierarchy','avia_framework' ), 'id'=>'hierarchy', 'page'=>array('page'), 'context'=>'side', 'priority'=>'low'),
    );

    return $boxes;
}



add_filter('avia_load_shortcodes', 'avia_include_shortcode_template', 15, 1);
function avia_include_shortcode_template($paths)
{
    $template_url = get_stylesheet_directory();
    array_unshift($paths, $template_url.'/shortcodes/');

    return $paths;
}

/**
 * This is here to hide the default cart header item
 */
function avia_woocommerce_cart_placement()
{
}

add_filter( 'wp_nav_menu_items', 'ela_custom_menu_item', 0, 2 );
function ela_custom_menu_item ( $items, $args )
{
    if (is_object($args) && $args->theme_location == 'avia') {
        $sl  = do_shortcode('[product_box_steaklocker]');
        $slp = do_shortcode('[product_box_steaklocker_pro]');
        $wl  = do_shortcode('[product_box_winelocker]');
        $bl  = do_shortcode('[product_box_beerlocker]');

        $items = ela_product_dropdown($sl, $slp, $wl, $bl) . $items . ela_woocommerce_cart_dropdown() . ela_menu_acct();
    }
    return $items;
}
function ela_product_dropdown($a, $b, $c, $d)
{
    $drop = <<<DROP
<li id="menu-item-products" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-has-children menu-item-mega-parent  menu-item-top-level menu-item-top-level-1 dropdown_ul_available" style="overflow: hidden;">
    <a href="#" itemprop="url" class="">
        <span class="avia-bullet"></span>
        <span class="avia-menu-text">Products</span>
        <span class="avia-menu-fx"><span class="avia-arrow-wrap"><span class="avia-arrow"></span></span></span>
        <span class="dropdown_available"></span>
    </a>
    <div class="avia_mega_div avia_mega4 twelve units" style="opacity: 0; display: none; right: -921.234px;">
        <ul class="sub-menu no-boxes">
DROP;

    $drop .= '<li class="menu-item menu-item-type-post_type menu-item-object-page avia_mega_menu_columns_4 three units">'. $a .'</li>';
    $drop .= '<li class="menu-item menu-item-type-post_type menu-item-object-page avia_mega_menu_columns_4 three units">'. $b .'</li>';
    $drop .= '<li class="menu-item menu-item-type-post_type menu-item-object-page avia_mega_menu_columns_4 three units">'. $c .'</li>';
    $drop .= '<li class="menu-item menu-item-type-post_type menu-item-object-page avia_mega_menu_columns_4 three units">'. $d .'</li>';
    $drop .= '</ul></div></li>';
    return $drop;
}

function ela_woocommerce_cart_dropdown()
{
    global $woocommerce, $avia_config;

    /** @var WooCommerce $woocommerce */
    $count = $woocommerce->cart->get_cart_contents_count();

    //print'<pre>'.print_r($woocommerce,1).'</pre>';
    //exit();
    $output = <<<HTML

<li id="menu-item-shop" class="cart_dropdown menu-item menu-item-type-post_type menu-item-object-page menu-item-has-children menu-item-mega-parent  menu-item-top-level menu-item-top-level-1 dropdown_ul_available" style="overflow: hidden;">
    <a href="/cart/" itemprop="url" class="">
        <span class="avia-bullet"></span>
        <span class="avia-menu-text">Cart</span>
        <span class="avia-menu-fx"><span class="avia-arrow-wrap"><span class="avia-arrow"></span></span></span>
        <span class="dropdown_available"></span>
        <span class="av-cart-counter av-active-counter">{$count}</span>
    </a>
    
HTML;

    //$output .= '<div class="avia_mega_div avia_mega4 dropdown_widget dropdown_widget_cart"><div class="xsub-menu"><div class="avia-arrow"></div>';
    //$output .= '<div class="widget_shopping_cart_content"></div>';
    //$output .= "</div></div>";
    //$output .= "</li>";
    return $output;

}

function ela_menu_acct()
{
    /** @var WP_User $user */
    $user = wp_get_current_user();
    $logged_in = ($user->ID != 0);

    $output = '<li id="menu-item-acct" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-top-level menu-item-top-level-5">';
    if ($logged_in) {
        $imageUrl = um_get_avatar_url(um_user('profile_photo', 200));

        $img = '<span id="my-profile-image" style="background-image:url('.$imageUrl.');"></span>';
        $output.= '<a id="my-profile-link" href="/account/" itemprop="url">'.$img.'<span class="avia-bullet"></span><span class="avia-menu-fx"><span class="avia-arrow-wrap"><span class="avia-arrow"></span></span></span></a>';
    }
    else {
        $output.= '<a href="/login/" itemprop="url"><span class="avia-bullet"></span><span class="avia-menu-text">Log In</span><span class="avia-menu-fx"><span class="avia-arrow-wrap"><span class="avia-arrow"></span></span></span></a>';
    }
    $output .= '</li>';
    return $output;
}



add_action('woocommerce_before_main_content', 'ela_woocommerce_before_single_product', 1);
function ela_woocommerce_before_single_product() {

    $args = [
        'menu' => 'shop-menu',
        'menu_id' => 'shop-menu',
        'container_class' => 'shop-menu main_color',
        'fallback_cb' => '',
        'depth'=>1,
        'echo' => false,
    ];

    $menu = wp_nav_menu($args);
    echo $menu;
}

add_filter('woocommerce_stock_html','ela_woocommerce_stock_html');
function ela_woocommerce_stock_html()
{
    return '';
}

add_filter('woocommerce_related_products_args', 'ela_woocommerce_related_products_args');
function ela_woocommerce_related_products_args($args)
{
    $args['posts_per_page'] = 2;
    return $args;
}

function avia_post_nav(){
    return '';
}

// Remove meta WooCommerce
remove_action( 'woocommerce_single_product_summary', 'woocommerce_template_single_price', 10 );
remove_action( 'woocommerce_single_product_summary', 'woocommerce_template_single_meta', 40 );
//remove_action( 'woocommerce_after_single_product_summary', 'woocommerce_output_related_products', 20);
//remove_action( 'woocommerce_after_single_product_summary', 'avia_woocommerce_output_related_products', 20);
add_action( 'woocommerce_after_main_content', 'woocommerce_output_related_products', 5 );


remove_action( 'woocommerce_single_variation', 'woocommerce_single_variation', 10 );
add_action( 'woocommerce_before_single_variation', 'woocommerce_single_variation', 10 );

add_action('wp_enqueue_scripts', 'ela_woocommerce_template_single_price'); 
function ela_woocommerce_template_single_price() {
	global $post;
	$product = wc_get_product( $post );
	if ($product && $product->product_type == 'simple') {
		add_action( 'woocommerce_single_product_summary', 'woocommerce_template_single_price', 25 );
	}
}

remove_action( 'woocommerce_before_shop_loop', 'avia_woocommerce_before_shop_loop', 1);
add_action( 'woocommerce_before_shop_loop', 'ela_woocommerce_before_shop_loop', 1);

function ela_woocommerce_before_shop_loop()
{

    global $avia_config;
    if(isset($avia_config['dynamic_template'])) return;
    $markup = avia_markup_helper(array('context' => 'content','echo'=>false,'post_type'=>'products'));
    echo "<main class='template-shop content ".avia_layout_class( 'content' , false)." units' $markup><div class='entry-content-wrapper container'>";
}



function ela_my_orders( $atts ) {
    extract( shortcode_atts( array(
        'order_count' => -1
    ), $atts ) );

    ob_start();
    wc_get_template( 'myaccount/my-orders.php', array(
        'current_user'  => get_user_by( 'id', get_current_user_id() ),
        'order_count'   => $order_count
    ) );
    return ob_get_clean();
}
add_shortcode('my_orders', 'ela_my_orders');
