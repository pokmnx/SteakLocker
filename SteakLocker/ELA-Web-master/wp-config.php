<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

$dev = $_REQUEST['HTTP_HOST'] == 'dev.ela.com';

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'elalifes_wp');

/** MySQL database username */
define('DB_USER', 'elalifes_wpuser');

/** MySQL database password */
define('DB_PASSWORD', '5pXYW8Lmd9FfZftE');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'm33;d%=K7Vr_#fO-,d7/_4Ldj)2K[I#{VV7MtyeHlUePLwzM7?^oO`@XEn$TSV8b');
define('SECURE_AUTH_KEY',  ' {J{LXS+sC9M<- usIsE:tGXH|[MKm!7p#^ZzSub<3IqltuC>Pe!?zfNLd<o-L~I');
define('LOGGED_IN_KEY',    '};|babQ(y$t,bOlAIMJHhEm*bl;{|I#;]YBp>Y00}k5=>4J39saP|gn &{$WBZ.=');
define('NONCE_KEY',        'B{Cf(!u8e2^7_Q*m,FT1Rxx@ ,}:bGS}wWP5 u~u8?ax2r^[pOn2BCwX/7AS$;?A');
define('AUTH_SALT',        'vy$@l[pR?}AGw`b]P>8O-lIGHD|bG9m{PBb<DZk_d Ekq7 28H7H^YzmvT6q-zA_');
define('SECURE_AUTH_SALT', 'GvFVei[?MtNotT)B ZrSNZ:= a$Irq*Mvui?1O-npR@S83(frg04M(rop.7u7g2N');
define('LOGGED_IN_SALT',   'q~V;vtF)p8lxZceakqAQI qv^;!,40O-G^Ay[hg!Az=?$f2!4D+@B0|s$cL2EcKr');
define('NONCE_SALT',       '$RwDlGp`.RDrFdd&4IbE?(c[*CMb]W]a,H=i;]zsqOJKz8A=,}45=uJ_.C1D@#cC');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
