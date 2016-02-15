<%@ page import="org.codehaus.groovy.grails.web.servlet.GrailsApplicationAttributes" %>
<!doctype html>

<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->

  <head>
    <meta charset="utf-8">
    <title><g:layoutTitle default="${meta(name: 'app.name')}"/></title>
    <meta name="description" content="">
    <meta name="author" content="">

    <meta name="viewport" content="initial-scale = 1.0">
    <r:require modules="kbplus"/>


    <!-- Le HTML5 shim, for IE6-8 support of HTML elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <g:layoutHead/>
    <r:layoutResources/>

    <tmpl:/layouts/analytics />
  </head>

  <body class="public">

 <script>
    dataLayer = [{
     'Institution': '${params.shortcode}',
     'UserDefaultOrg': '${user?.defaultDash?.shortcode}',
     'UserRole': 'ROLE_USER'
    }];
  </script>
<!-- Google Tag Manager - Placed here as instructed by MB 20/01/2016, made aware of possible negative impacts -->
<noscript><iframe src="//www.googletagmanager.com/ns.html?id=GTM-5BMV57"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-5BMV57');</script>
<!-- End Google Tag Manager -->

    <g:layoutBody/>
    
    <div id="Footer">
      <div class="navbar navbar-footer">
          <div class="navbar-inner">
              <div class="container">
                  <div>
                      <ul class="footer-sublinks nav">
                          <li><a href="${createLink(uri: '/terms-and-conditions')}">Terms & Conditions</a></li>
                          <li><a href="${createLink(uri: '/privacy-policy')}">Privacy Policy</a></li>
                          <li><a href="${createLink(uri: '/freedom-of-information-policy')}">Freedom of Information Policy</a></li>
                      </ul>
                  </div>
              </div>
          </div>
      </div>
          
      <div class="clearfix"></div>
          
      <div class="footer-links container">
          <div class="row">
              <div class="pull-left">
                  <a href="http://www.jisc-collections.ac.uk/"><div class="sprite sprite-jisc_collections_logo">JISC Collections</div></a>
              </div>
              <div class="pull-right">
                  <a href="http://www.kbplus.ac.uk"><div class="sprite sprite-kbplus_logo">Knowledge Base Plus</div></a>
              </div>
          </div>
      </div>
  </div>
    <r:layoutResources/>
  </body>

</html>
