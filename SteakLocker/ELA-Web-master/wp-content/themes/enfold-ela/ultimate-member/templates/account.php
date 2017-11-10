<div id="ela-dashboard">

<div class="tabcontainer  top_tab   avia-builder-el-8  el_after_av_section   avia-builder-el-first ">

	<section class="av_tab_section" itemscope="itemscope" itemtype="https://schema.org/CreativeWork">
		<div data-fake-id="#monitoring" class="tab active_tab fullsize-tab" itemprop="headline">Monitoring</div>
		<div id="monitoring-container" class="tab_content active_tab_content">
			<div class="tab_inner_content invers-color" itemprop="text">
			<?php echo do_shortcode(ela_dashboard_devices()); ?>
			</div>
		</div>
	</section>

	<?php

	/*
	<section class="av_tab_section" itemscope="itemscope" itemtype="https://schema.org/CreativeWork">
		<div data-fake-id="#orders" class="tab  fullsize-tab" itemprop="headline">My Orders</div>
		<div id="orders-container" class="tab_content ">
			<div class="tab_inner_content invers-color" itemprop="text">
				// echo do_shortcode('[my_orders]'); ?>


			</div>
		</div>
	</section>
	*/
	?>

	<section class="av_tab_section" itemscope="itemscope" itemtype="https://schema.org/CreativeWork">
		<div data-fake-id="#settings" class="tab  fullsize-tab" itemprop="headline">Settings</div>
		<div id="settings-container" class="tab_content ">
			<div class="tab_inner_content invers-color" itemprop="text">




<div class="um <?php echo $this->get_class( $mode ); ?> um-<?php echo $form_id; ?>">

	<div class="um-form">
	
		<form method="post" action="">
			
			<?php do_action('um_account_page_hidden_fields', $args ); ?>

			<?php do_action('um_profile_header', $args ); ?>


			<div style="display:none" class="um-account-side uimob340-hide uimob500-hide">
				<?php
				do_action('um_account_display_tabs_hook', $args );
				?>
			</div>
			
			<div class="um-account-main" data-current_tab="<?php echo $ultimatemember->account->current_tab; ?>">
			
				<?php
				
				do_action('um_before_form', $args);
				
				foreach( $ultimatemember->account->tabs as $k => $arr ) {

					foreach( $arr as $id => $info ) { extract( $info );
					
						$current_tab = $ultimatemember->account->current_tab;

						if ( isset($info['custom']) || um_get_option('account_tab_'.$id ) == 1 || $id == 'general' ) {

							?>
							
							<div class="um-account-nav uimob340-show uimob500-show"><a href="#" data-tab="<?php echo $id; ?>" class="<?php if ( $id == $current_tab ) echo 'current'; ?>"><?php echo $title; ?>
								<span class="ico"><i class="<?php echo $icon; ?>"></i></span>
								<span class="arr"><i class="um-faicon-angle-down"></i></span>
							</a></div>
							
							<?php
							
							echo '<div class="um-account-tab um-account-tab-'.$id.'" data-tab="'.$id.'">';

								do_action("um_account_tab__{$id}", $info );
							
							echo '</div>';
						
						}
						
					}
					
				}
				
				?>
				
			</div><div class="um-clear"></div>
			
		</form>
		
		<?php do_action('um_after_account_page_load'); ?>
	
	</div>
	
</div>



			</div>
		</div>
	</section>

</div><!-- /.tabcontainer -->
</div><!-- /.ela-dashboard -->
<script src="https://npmcdn.com/parse/dist/parse.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.17.1/moment.min.js"></script>


<?php
/*
$elaUser = ela_get_linked_users();
$sessionId = ($elaUser) ? $elaUser->ela_session_id : '';
if ($sessionId) {

?>
<script>
jQuery(function($) {
	Parse.User.become('<?php echo $sessionId; ?>').then(function (user) {
		console.log(user);
	}, function (error) {

	});
})
</script>
<?php

}
*/
?>