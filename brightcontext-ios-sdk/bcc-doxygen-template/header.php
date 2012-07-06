<?php 
    define('WP_USE_THEMES', false);
    require('../../wp-blog-header.php');

    $page_template = 'single-doc doxygen';

    get_header();
?>

<link rel="styleshet" href="/docs/ios/doxygen.css" />

<div class="container interior-container" itemscope itemtype="http://schema.org/Article">
    
    <header class="content-header">
        <h2 itemprop="name">BrightContext Documentation</h2>
    </header>
    
    <div role="complementary" class="leftcolumn" id="docs-sidebar-nav">
        
        <h3 class="visually-hidden">Documentation Navigation</h3>
        
        <?php //get_template_part('searchform-docs'); ?>