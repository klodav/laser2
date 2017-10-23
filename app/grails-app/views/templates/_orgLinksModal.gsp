<div id="osel_add_modal" class="modal hide">

    <g:form id="create_org_role_link" url="[controller:'ajax',action:'addOrgRole']" method="post" onsubmit="return validateAddOrgRole();">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">×</button>
            <h3>${message(code:'template.orgLinksModal')}</h3>
        </div>

        <input type="hidden" name="parent" value="${parent}"/>
        <input type="hidden" name="property" value="${property}"/>
        <input type="hidden" name="recip_prop" value="${recip_prop}"/>
        <div class="modal-body">
            <dl>
                <dt><label class="control-label">${message(code:'template.orgLinksModal.label')}</label></dt>
                <dd>
                    <table id="org_role_tab" class="table table-bordered">
                        <thead>
                            <tr id="add_org_head_row">
                            </tr>
                        </thead>
                    </table>
                </dd>
            </dl>

            <dl>         
                <dt><label class="control-label">${message(code:'template.orgLinksModal.role')}</label></dt>
                <dd>    
                <g:if test="${linkType}">
                    <g:select name="orm_orgRole"
                          noSelection="${['':'Select One...']}" 
                          from="${com.k_int.kbplus.RefdataValue.findAllByOwnerAndGroup(com.k_int.kbplus.RefdataCategory.findByDesc('Organisational Role'),linkType)}" 
                          optionKey="id" 
                          optionValue="${{it.getI10n('value')}}"/>
                </g:if>
                <g:else>
                    <g:select name="orm_orgRole" 
                          noSelection="${['':'Select One...']}" 
                          from="${com.k_int.kbplus.RefdataValue.findAllByOwner(com.k_int.kbplus.RefdataCategory.findByDesc('Organisational Role'))}" 
                          optionKey="id" 
                          optionValue="${{it.getI10n('value')}}"/>
                </g:else>
                </dd>
            </dl>

        </div>

        <div class="modal-footer">
            <input id="org_role_add_btn" type="submit" class="btn btn-primary" value="${message(code:'default.button.add.label')}" />
            <a href="#" data-dismiss="modal" class="btn btn-primary">${message(code:'default.button.close.label')}</a>
        </div>
    </g:form>

</div>

<g:javascript>
    var oOrTable;

    $(document).ready(function(){

        $('#add_org_head_row').empty();
        $('#add_org_head_row').append("<td>${message(code:'template.orgLinksModal.name.label')}</td>");
        $('#add_org_head_row').append("<td>${message(code:'template.orgLinksModal.select')}</td>");

        oOrTable = $('#org_role_tab').dataTable( {
            'bAutoWidth': true,
            "sScrollY": "200px",
            "sAjaxSource": "<g:createLink controller="ajax" action="refdataSearch" id="ContentProvider" params="${[format:'json']}"/>",
            "bServerSide": true,
            "bProcessing": true,
            "bDestroy":true,
            "bSort":false,
            "sDom": "frtiS",
            "oScroller": {
                "loadingIndicator": false
            },
            "aoColumnDefs": [ {
                    "aTargets": [ 1 ],
                    "mData": "DT_RowId",
                    "mRender": function ( data, type, full ) {
                        return '<input type="checkbox" name="orm_orgoid" value="'+data+'"/>';
                    }
                } ]
        } );

        oOrTable.fnAdjustColumnSizing();

    });

    function validateAddOrgRole() {
      if ( $('#orm_orgRole').val() == '' ) {
        // alert('hello "'+ $('#orm_orgRole').val()+'"'); 
        return confirm("${message(code:'template.orgLinksModal.warn')}");
      }

      return true;
    }


</g:javascript>
