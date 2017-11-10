<?php
if ( !defined('ABSPATH') ){ die(); }

global $avia_config;

if( get_post_meta(get_the_ID(), 'header', true) != 'no') echo avia_title(array('heading'=>'strong', 'title' => $title, 'link' => $t_link, 'subtitle' => $t_sub));

do_action( 'ava_after_main_title' );

?>
    <div class='container_wrap container_wrap_first main_color <?php avia_layout_class( 'main' ); ?>'>

        <div class='container template-snippet template-single-snippet '>

                <?php
                /* Run the loop to output the posts.
                * If you want to overload this in a child theme then include a file
                * called loop-index.php and that will be used instead.
                *
                */

                get_template_part( 'includes/loop', 'index' );

                ?>

                <!--end content-->

        </div><!--end container-->

    </div><!-- close default .container_wrap element -->
