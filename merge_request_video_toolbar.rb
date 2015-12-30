+++ b/app/views/content_viewer/_article_toolbar.html.erb
@@ -29,7 +29,9 @@
         <%= expirable_button @page, :locale, content, url %>
       <% end %>

-      <%= modal_button(:new, label_for_new_article(@page), profile.admin_url.merge(:controller => 'cms', :action => 'new', :parent_id => (@page.folder? ? @pa
+      <% if !@page.archived? %>
+        <%= modal_button(:new, label_for_new_article(@page), profile.admin_url.merge(:controller => 'cms', :action => 'new', :parent_id => (@page.folder? ? @
+      <% end %>

       <% content = content_tag('span', label_for_clone_article(@page)) %>
       <% url = profile.admin_url.merge({ :controller => 'cms', :action => 'new', :id => @page.id, :clone => true,  :parent_id => (@page.folder? ? @page : @pa
@@ -61,6 +63,9 @@
     <% end %>
     <%= button_without_text(:feed, _('RSS feed'), @page.feed.url, :class => 'blog-feed-link') if @page.has_posts? && @page.feed %>
     <%= @plugins.dispatch(:article_header_extra_contents, @page).collect { |content| instance_exec(&content) }.join("") %>
+    <% if @page.archived? %>
+      <%= render :partial => 'cms/archived_warning', :locals => {:article => @page} %>
+    <% end %>
     <%= render :partial => 'article_title', :locals => {:no_link => true} %>
     <%= article_translations(@page) %>
   </div>
