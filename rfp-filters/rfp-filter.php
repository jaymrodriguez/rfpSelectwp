<?php
/**
 * Plugin Name: RFP Filters
 * Description: Adds custom filtres to RFP Select website.
 * Author: Randy Perez
 * Version: 1.0
 *
 *
 * License: GNU General Public License v3.0
 * License URI: http://www.gnu.org/licenses/gpl-3.0.html
 *
 * @author    Randy Perez
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU General Public License v3.0
 *
 */

add_filter( 'rest_location_query', function( $args ) {
	$args['meta_query'] = array(
		array(
			'key'   => 'company_id',
			'value' => esc_sql( $_GET['company_id'] ),
		)
	);

	return $args;
} );

defined( 'ABSPATH' ) or exit;