	</div>
</div><!--container-fluid-->

<script>
	
	(function($) {
		
		"use strict";
		
		var __tmpl = $('<ul id="menu-documentation-page-sidebar" class="nav docs">' +
							'<li><a href="<?php viget_get_permalink_by_name("Overview", "page")?>">Overview</a></li>' +
							'<li><a href="<?php viget_get_permalink_by_name("From 0 to 60", 'page')?>">Quickstart</a></li>' +
							'<li><a href="<?php viget_get_permalink_by_name("Platform Guide", "doc")?>">Platform Guide</a></li>' +
							'<li><a href="/docs/js">JS SDK Guide</a></li>' +
							'<li class="current-menu-item"><a href="/docs/ios">iOS SDK Guide</a></li>' +
              '<li><a href="/fdu">Diagnostic Tool</a></li>' +
							'<li><a href="http://github.com/brightcontext">Libraries</a></li>' +
						'</ul>');
	
		// First, we clone the iOS documentation
		var $row1 = $("#navrow1").clone(true),
			$row2 = $("#navrow2").clone(true),
			$row3 = $("#navrow3").clone(true);
	
		// Second, load in the sidebar
		$(".leftcolumn").empty().append(__tmpl);
	
		$(".leftcolumn li.current-menu-item").append($row1);

		if ( $row2.length ) {
			$row1.addClass("parent");
			$row2.appendTo("#navrow1 li.current");
		}

		if ( $row3.length ) {
			$row2.addClass("parent");
			$row3.detach().appendTo($row2);
		}

	}(window.jQuery));
	
</script>

<?php get_footer(); ?>
