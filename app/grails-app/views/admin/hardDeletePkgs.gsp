<!doctype html>
<html>
  <head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code:'laser', default:'LAS:eR')} Admin::Package Delete</title>
    <r:require module='annotations' />
  </head>

  <body>

      <ul class="breadcrumb">
        <li> <g:link controller="home" action="index">Home</g:link> <span class="divider">/</span> </li>
        <li> <g:link controller="admin" action="hardDeletePkgs">Package Delete </g:link> </li>
      </ul>

      <semui:messages data="${flash}" />

          <g:form action="hardDeletePkgs" method="get" params="${params}">
          <input type="hidden" name="offset" value="${params.offset}"/>

          <div class="well form-horizontal">
            Name: <input name="pkg_name" placeholder="Partial terms accepted" value="${params.pkg_name}"/>
            <button type="submit" name="search" value="yes">Search</button>
          </div>
          </g:form>

        <table class="ui sortable table">
          <thead>
            <tr>
              <g:sortableColumn property="name" title="${message(code: 'package.name.label', default: 'Name')}" />
              <th></th>
            </tr>
          </thead>
          <tbody>
          <g:each in="${pkgs}" var="packageInstance">
            <tr>
              <td>
              <g:link controller="packageDetails" action="show" id="${packageInstance.id}">
              ${fieldValue(bean: packageInstance, field: "name")} (${packageInstance?.contentProvider?.name})</g:link>
              </td>            
              <td class="link">
                <button onclick="showDetails(${packageInstance.id});" class="ui tiny button">Prepare Delete</button>
              </td>
            </tr>
          </g:each>
          </tbody>
        </table>

      <div class="paginateButtons" style="text-align:center">
        <span><g:paginate action="hardDeletePkgs" params="${params}" next="Next" prev="Prev" total="${pkgs.totalCount}" /></span>
      </div>


        <div id="packageDetails_div"></div>

        <g:javascript>
        function showDetails(id){
          jQuery.ajax({type:'get', url:"${createLink(controller:'admin', action:'hardDeletePkgs')}"+"/"+id,success:function(data,textStatus){jQuery('#packageDetails_div').html(data);$("#pkg_details_modal").modal("show")},error:function(XMLHttpRequest,textStatus,errorThrown){}
        });
        }
        </g:javascript>

  </body>
</html>     