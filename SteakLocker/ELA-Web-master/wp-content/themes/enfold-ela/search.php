<?php
if ( !defined('ABSPATH') ){ die(); }

global $avia_config;


/*
 * get_header is a basic wordpress function, used to retrieve the header.php file in your theme directory.
 */
get_header();

//	allows to customize the layout
do_action( 'ava_search_after_get_header' );


$results = avia_which_archive();
echo avia_title(array('title' => $results ));

do_action( 'ava_after_main_title' );
?>

<div class='container_wrap container_wrap_first main_color <?php avia_layout_class( 'main' ); ?>'>


    <div id="av_section_1" class="avia-section main_color avia-section-default avia-no-shadow avia-full-stretch avia-bg-style-scroll  avia-builder-el-0  el_before_av_section  avia-builder-el-first  container_wrap fullsize" style="background-repeat: no-repeat; background-image: url(http://dev.ela.com/wp-content/uploads/2016/07/snap.jpg); background-attachment: scroll; background-position: center center; " data-section-bg-repeat="stretch"><div class="container"><main role="main" itemprop="mainContentOfPage" class="template-page content  av-content-full alpha units"><div class="post-entry post-entry-type-page post-entry-55"><div class="entry-content-wrapper clearfix">
        <section class="av_textblock_section" itemscope="itemscope" itemtype="https://schema.org/CreativeWork"><div class="avia_textblock " itemprop="text">
                <?php
                get_search_form();
                ?>
            </div></section>
    </div></div></main><!-- close content main element --></div></div>


    <div class='container'>





        <main class='content template-search <?php avia_layout_class( 'content' ); ?> units' <?php avia_markup_helper(array('context' => 'content'));?>>
            <?php
            if(!empty($_GET['s']) || have_posts())
            {
                echo "<h4 class='extra-mini-title widgettitle'>{$results}</h4>";

                /* Run the loop to output the posts.
                * If you want to overload this in a child theme then include a file
                * called loop-search.php and that will be used instead.
                */
                $more = 0;
                get_template_part( 'includes/loop', 'search' );

            }

            ?>

            <!--end content-->
        </main>

        <?php

        //get the sidebar
        $avia_config['currently_viewing'] = 'page';

        get_sidebar();

        ?>

    </div><!--end container-->

</div><!-- close default .container_wrap element -->




<?php get_footer(); ?>
