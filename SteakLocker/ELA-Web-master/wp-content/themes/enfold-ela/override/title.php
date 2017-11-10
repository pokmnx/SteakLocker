<?php

function avia_title($args = false, $id = false)
{
    global $avia_config, $wp;

    $current_url = add_query_arg([],$wp->request);
    $parts = explode('/', $current_url);

    if (is_front_page() || count($parts) <= 1) {
        return;
    }

    if(!$id) $id = avia_get_the_id();

    $header_settings = avia_header_setting();
    if($header_settings['header_title_bar'] == 'hidden_title_bar') return "";

    $defaults 	 = array(

        'title' 		=> get_the_title($id),
        'subtitle' 		=> "", //avia_post_meta($id, 'subtitle'),
        'link'			=> get_permalink($id),
        'html'			=> "<div class='{class} title_container'><div class='container'><{heading} class='main-title entry-title'>{title}</{heading}>{additions}</div></div>",
        'class'			=> 'stretch_full container_wrap alternate_color '.avia_is_dark_bg('alternate_color', true),
        'breadcrumb'	=> true,
        'additions'		=> "",
        'heading'		=> 'h1' //headings are set based on this article: http://yoast.com/blog-headings-structure/
    );

    if ( is_tax() || is_category() || is_tag() )
    {
        global $wp_query;

        $term = $wp_query->get_queried_object();
        $defaults['link'] = get_term_link( $term );
    }
    else if(is_archive())
    {
        $defaults['link'] = "";
    }


    // Parse incomming $args into an array and merge it with $defaults
    $args = wp_parse_args( $args, $defaults );
    $args = apply_filters('avf_title_args', $args, $id);

    //disable breadcrumb if requested
    if($header_settings['header_title_bar'] == 'title_bar') $args['breadcrumb'] = false;

    //disable title if requested
    if($header_settings['header_title_bar'] == 'breadcrumbs_only') $args['title'] = '';


    // OPTIONAL: Declare each item in $args as its own variable i.e. $type, $before.
    extract( $args, EXTR_SKIP );

    if(empty($title)) $class .= " empty_title ";
    $markup = avia_markup_helper(array('context' => 'avia_title','echo'=>false));
    if(!empty($link) && !empty($title)) $title = "<a href='".$link."' rel='bookmark' title='".__('Permanent Link:','avia_framework')." ".esc_attr( $title )."' $markup>".$title."</a>";
    if(!empty($subtitle)) $additions .= "<div class='title_meta meta-color'>".wpautop($subtitle)."</div>";
    if($breadcrumb) $additions .= ela_breadcrumbs(array('separator' => '/', 'richsnippet' => true));


    $html = str_replace('{class}', $class, $html);
    $html = str_replace('{title}', $title, $html);
    $html = str_replace('{additions}', $additions, $html);
    $html = str_replace('{heading}', $heading, $html);



    if(!empty($avia_config['slide_output']) && !avia_is_dynamic_template($id) && !avia_is_overview())
    {
        $avia_config['small_title'] = $title;
    }
    else
    {
        return $html;
    }
}



function ela_breadcrumbs( $args = [] ) {
    global $wp_query, $wp_rewrite;

    /* Create an empty variable for the breadcrumb. */
    $breadcrumb = '';

    /* Create an empty array for the trail. */
    $trail = [];
    $path = '';

    /* Set up the default arguments for the breadcrumb. */
    $defaults = [
        'separator' => '&raquo;',
        'before' => false,
        'after' => false,
        'front_page' => false,
        'show_home' => __( 'Home', 'avia_framework' ),
        'echo' => false,
        'show_categories' => true,
        'show_posts_page' => true,
        'truncate' => 70,
        'richsnippet' => false
    ];


    /* Allow singular post views to have a taxonomy's terms prefixing the trail. */
    if ( is_singular() )
        $defaults["singular_{$wp_query->post->post_type}_taxonomy"] = false;

    /* Apply filters to the arguments. */
    $args = apply_filters( 'avia_breadcrumbs_args', $args );

    /* Parse the arguments and extract them for easy variable naming. */
    extract( wp_parse_args( $args, $defaults ) );

    /* If $show_home is set and we're not on the front page of the site, link to the home page. */
    if ( !is_front_page() && $show_home )
        $trail[] = '<a href="' . home_url() . '" title="' . esc_attr( get_bloginfo( 'name' ) ) . '" rel="home" class="trail-begin">' . $show_home . '</a>';

    /* If viewing the front page of the site. */
    if ( is_front_page() ) {
        if ( !$front_page )
            $trail = false;
        elseif ( $show_home )
            $trail['trail_end'] = "{$show_home}";
    }

    /* If viewing the "home"/posts page. */
    elseif ( is_home() ) {
        $home_page = get_page( $wp_query->get_queried_object_id() );
        $trail = array_merge( $trail, avia_breadcrumbs_get_parents( $home_page->post_parent, '' ) );
        $trail['trail_end'] = get_the_title( $home_page->ID );
    }

    /* If viewing a singular post (page, attachment, etc.). */
    elseif ( is_singular() ) {

        /* Get singular post variables needed. */
        $post = $wp_query->get_queried_object();
        $post_id = absint( $wp_query->get_queried_object_id() );
        $post_type = $post->post_type;
        $parent = $post->post_parent;


        /* If a custom post type, check if there are any pages in its hierarchy based on the slug. */
        if ( 'page' !== $post_type && 'post' !== $post_type ) {

            $post_type_object = get_post_type_object( $post_type );

            /* If $front has been set, add it to the $path. */
            if ( 'post' == $post_type || 'attachment' == $post_type || ( $post_type_object->rewrite['with_front'] && $wp_rewrite->front ) )
                $path .= trailingslashit( $wp_rewrite->front );

            /* If there's a slug, add it to the $path. */
            if ( !empty( $post_type_object->rewrite['slug'] ) )
                $path .= $post_type_object->rewrite['slug'];

            /* If there's a path, check for parents. */
            if ( !empty( $path ) )
                $trail = array_merge( $trail, avia_breadcrumbs_get_parents( '', $path ) );

            /* If there's an archive page, add it to the trail. */
            if ( !empty( $post_type_object->has_archive ) && function_exists( 'get_post_type_archive_link' ) )
                $trail[] = '<a href="' . get_post_type_archive_link( $post_type ) . '" title="' . esc_attr( $post_type_object->labels->name ) . '">' . $post_type_object->labels->name . '</a>';
        }

        /* try to build a generic taxonomy trail no matter the post type and taxonomy and terms
        $currentTax = "";
        foreach(get_taxonomies() as $tax)
        {
            $terms = get_the_term_list( $post_id, $tax, '', '$$$', '' );
            echo"<pre>";
            print_r($tax.$terms);
            echo"</pre>";
        }
        */

        /* If the post type path returns nothing and there is a parent, get its parents. */
        if ( empty( $path ) && 0 !== $parent || 'attachment' == $post_type )
            $trail = array_merge( $trail, avia_breadcrumbs_get_parents( $parent, '' ) );

        /* Toggle the display of the posts page on single blog posts. */
        if ( 'post' == $post_type && $show_posts_page == true && 'page' == get_option( 'show_on_front' ) ) {
            $posts_page = get_option( 'page_for_posts' );
            if ( $posts_page != '' && is_numeric( $posts_page ) ) {
                $trail = array_merge( $trail, avia_breadcrumbs_get_parents( $posts_page, '' ) );
            }
        }

        if('post' == $post_type && $show_categories)
        {
            $category = get_the_category();

            foreach($category as $cat)
            {
                if(!empty($cat->parent))
                {
                    $parents = get_category_parents($cat->cat_ID, TRUE, '$$$', FALSE );
                    $parents = explode("$$$", $parents);
                    foreach ($parents as $parent_item)
                    {
                        if($parent_item) $trail[] = $parent_item;
                    }
                    break;
                }
            }

            if(isset($category[0]) && empty($parents))
            {
                $trail[] = '<a href="'.get_category_link($category[0]->term_id ).'">'.$category[0]->cat_name.'</a>';
            }

        }

        if($post_type == 'portfolio')
        {
            $parents = get_the_term_list( $post_id, 'portfolio_entries', '', '$$$', '' );
            $parents = explode('$$$',$parents);
            foreach ($parents as $parent_item)
            {
                if($parent_item) $trail[] = $parent_item;
            }
        }

        /* Display terms for specific post type taxonomy if requested. */
        if ( isset( $args["singular_{$post_type}_taxonomy"] ) && $terms = get_the_term_list( $post_id, $args["singular_{$post_type}_taxonomy"], '', ', ', '' ) )
            $trail[] = $terms;

        /* End with the post title. */
        $post_title = get_the_title( $post_id ); // Force the post_id to make sure we get the correct page title.
        if ( !empty( $post_title ) )
            $trail['trail_end'] = $post_title;

    }

    /* If we're viewing any type of archive. */
    elseif ( is_archive() ) {

        /* If viewing a taxonomy term archive. */
        if ( is_tax() || is_category() || is_tag() ) {

            /* Get some taxonomy and term variables. */
            $term = $wp_query->get_queried_object();
            $taxonomy = get_taxonomy( $term->taxonomy );

            /* Get the path to the term archive. Use this to determine if a page is present with it. */
            if ( is_category() )
                $path = get_option( 'category_base' );
            elseif ( is_tag() )
                $path = get_option( 'tag_base' );
            else {
                if ( $taxonomy->rewrite['with_front'] && $wp_rewrite->front )
                    $path = trailingslashit( $wp_rewrite->front );
                $path .= $taxonomy->rewrite['slug'];
            }

            /* Get parent pages by path if they exist. */
            if ( $path )
                $trail = array_merge( $trail, avia_breadcrumbs_get_parents( '', $path ) );

            /* If the taxonomy is hierarchical, list its parent terms. */
            if ( is_taxonomy_hierarchical( $term->taxonomy ) && $term->parent )
                $trail = array_merge( $trail, avia_breadcrumbs_get_term_parents( $term->parent, $term->taxonomy ) );

            /* Add the term name to the trail end. */
            $trail['trail_end'] = $term->name;
        }

        /* If viewing a post type archive. */
        elseif ( function_exists( 'is_post_type_archive' ) && is_post_type_archive() ) {

            /* Get the post type object. */
            $post_type_object = get_post_type_object( get_query_var( 'post_type' ) );

            /* If $front has been set, add it to the $path. */
            if ( $post_type_object->rewrite['with_front'] && $wp_rewrite->front )
                $path .= trailingslashit( $wp_rewrite->front );

            /* If there's a slug, add it to the $path. */
            if ( !empty( $post_type_object->rewrite['archive'] ) )
                $path .= $post_type_object->rewrite['archive'];

            /* If there's a path, check for parents. */
            if ( !empty( $path ) )
                $trail = array_merge( $trail, avia_breadcrumbs_get_parents( '', $path ) );

            /* Add the post type [plural] name to the trail end. */
            $trail['trail_end'] = $post_type_object->labels->name;
        }

        /* If viewing an author archive. */
        elseif ( is_author() ) {

            /* If $front has been set, add it to $path. */
            if ( !empty( $wp_rewrite->front ) )
                $path .= trailingslashit( $wp_rewrite->front );

            /* If an $author_base exists, add it to $path. */
            if ( !empty( $wp_rewrite->author_base ) )
                $path .= $wp_rewrite->author_base;

            /* If $path exists, check for parent pages. */
            if ( !empty( $path ) )
                $trail = array_merge( $trail, avia_breadcrumbs_get_parents( '', $path ) );

            /* Add the author's display name to the trail end. */
            $trail['trail_end'] =  apply_filters('avf_author_name', get_the_author_meta('display_name', get_query_var('author')), get_query_var('author'));
        }

        /* If viewing a time-based archive. */
        elseif ( is_time() ) {

            if ( get_query_var( 'minute' ) && get_query_var( 'hour' ) )
                $trail['trail_end'] = get_the_time( __( 'g:i a', 'avia_framework' ) );

            elseif ( get_query_var( 'minute' ) )
                $trail['trail_end'] = sprintf( __( 'Minute %1$s', 'avia_framework' ), get_the_time( __( 'i', 'avia_framework' ) ) );

            elseif ( get_query_var( 'hour' ) )
                $trail['trail_end'] = get_the_time( __( 'g a', 'avia_framework' ) );
        }

        /* If viewing a date-based archive. */
        elseif ( is_date() ) {

            /* If $front has been set, check for parent pages. */
            if ( $wp_rewrite->front )
                $trail = array_merge( $trail, avia_breadcrumbs_get_parents( '', $wp_rewrite->front ) );

            if ( is_day() ) {
                $trail[] = '<a href="' . get_year_link( get_the_time( 'Y' ) ) . '" title="' . get_the_time( esc_attr__( 'Y', 'avia_framework' ) ) . '">' . get_the_time( __( 'Y', 'avia_framework' ) ) . '</a>';
                $trail[] = '<a href="' . get_month_link( get_the_time( 'Y' ), get_the_time( 'm' ) ) . '" title="' . get_the_time( esc_attr__( 'F', 'avia_framework' ) ) . '">' . get_the_time( __( 'F', 'avia_framework' ) ) . '</a>';
                $trail['trail_end'] = get_the_time( __( 'j', 'avia_framework' ) );
            }

            elseif ( get_query_var( 'w' ) ) {
                $trail[] = '<a href="' . get_year_link( get_the_time( 'Y' ) ) . '" title="' . get_the_time( esc_attr__( 'Y', 'avia_framework' ) ) . '">' . get_the_time( __( 'Y', 'avia_framework' ) ) . '</a>';
                $trail['trail_end'] = sprintf( __( 'Week %1$s', 'avia_framework' ), get_the_time( esc_attr__( 'W', 'avia_framework' ) ) );
            }

            elseif ( is_month() ) {
                $trail[] = '<a href="' . get_year_link( get_the_time( 'Y' ) ) . '" title="' . get_the_time( esc_attr__( 'Y', 'avia_framework' ) ) . '">' . get_the_time( __( 'Y', 'avia_framework' ) ) . '</a>';
                $trail['trail_end'] = get_the_time( __( 'F', 'avia_framework' ) );
            }

            elseif ( is_year() ) {
                $trail['trail_end'] = get_the_time( __( 'Y', 'avia_framework' ) );
            }
        }
    }

    /* If viewing search results. */
    elseif ( is_search() )
        $trail['trail_end'] = sprintf( __( 'Search results for &quot;%1$s&quot;', 'avia_framework' ), esc_attr( get_search_query() ) );

    /* If viewing a 404 error page. */
    elseif ( is_404() )
        $trail['trail_end'] = __( '404 Not Found', 'avia_framework' );

    /* Allow child themes/plugins to filter the trail array. */
    $trail = apply_filters( 'avia_breadcrumbs_trail', $trail, $args );

    /* Connect the breadcrumb trail if there are items in the trail. */
    if ( is_array( $trail ) ) {

        $el_tag = "span";
        $vocabulary = "";

        //google rich snippets
        if($richsnippet === true)
        {
            $vocabulary = 'xmlns:v="http://rdf.data-vocabulary.org/#"';
        }

        /* Open the breadcrumb trail containers. */
        $breadcrumb = '<div class="breadcrumb breadcrumbs avia-breadcrumbs"><div class="breadcrumb-trail" '.$vocabulary.'>';

        /* If $before was set, wrap it in a container. */
        if ( !empty( $before ) )
            $breadcrumb .= '<'.$el_tag.' class="trail-before">' . $before . '</'.$el_tag.'> ';

        /* Wrap the $trail['trail_end'] value in a container. */
        if ( !empty( $trail['trail_end'] ) )
        {
            if(!is_search())
            {
                $trail['trail_end'] =  avia_backend_truncate($trail['trail_end'], $truncate, " ", $pad="...", false, '<strong><em><span>', true);
            }
            $trail['trail_end'] = '<'.$el_tag.' class="trail-end">' . $trail['trail_end'] . '</'.$el_tag.'>';
        }

        if($richsnippet === true)
        {
            foreach($trail as $key => &$link)
            {
                if("trail_end" == $key) continue;

                $link = preg_replace('!rel=".+?"|rel=\'.+?\'|!',"", $link);
                $link = str_replace('<a ', '<a rel="v:url" property="v:title" ', $link);
                //$link = '<span typeof="v:Breadcrumb">'.$link.'</span>'; //removed due to data testing error
                $link = '<span>'.$link.'</span>';
            }
        }


        /* Format the separator. */
        if ( !empty( $separator ) )
            $separator = '<span class="sep">' . $separator . '</span>';

        /* Join the individual trail items into a single string. */
        $breadcrumb .= join( " {$separator} ", $trail );

        /* If $after was set, wrap it in a container. */
        if ( !empty( $after ) )
            $breadcrumb .= ' <span class="trail-after">' . $after . '</span>';

        /* Close the breadcrumb trail containers. */
        $breadcrumb .= '</div></div>';
    }

    /* Allow developers to filter the breadcrumb trail HTML. */
    $breadcrumb = apply_filters( 'avia_breadcrumbs', $breadcrumb );

    /* Output the breadcrumb. */
    if ( $echo )
        echo $breadcrumb;
    else
        return $breadcrumb;

} // End avia_breadcrumbs()